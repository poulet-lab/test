classdef update
    
    properties (SetAccess = immutable)
        BaseDirectory
        LocalVersion
        RemoteVersion
        RemoteURL
        RemoteZIP
    end
    
    properties (Constant, Access = private)
        RepoName  = 'poulet-lab/test';
        RestBase  = 'https://api.github.com';
        RestOpts  = weboptions(...
            'ContentType',  'json', ...
            'MediaType',    'application/vnd.github.v3+json');
    end
        
    methods
        function obj = update(varargin)
            % test for internet connection
            if ~obj.testInternet()
                error('Can''t connect to the internet.')
            end

            % check for version control
            if exist(fullfile(obj.BaseDirectory,'.git'),'dir')
                url = sprintf('%s/repos/%s',...
                    obj.RestBase,obj.RepoName);
                link = [webread(url,obj.RestOpts).html_url '/releases'];
                error(['You are using intrinsic with GIT version ' ...
                    'control. Use GIT to update your local ' ...
                    'repository.\nAlternatively, manually download ' ...
                    'the newest release of intrinsic from ' ...
                    '<a href="matlab: web(''%s'');">%s</a>.\n'],link,link)
            end
            
            % get local version
            obj.LocalVersion = intrinsic.version;

            % get remote data from github
            url = sprintf('%s/repos/%s/releases',obj.RestBase,obj.RepoName);
            data = webread(url,obj.RestOpts);
            obj.RemoteURL = data(1).html_url;
            obj.RemoteZIP = data(1).zipball_url;
            obj.RemoteVersion = regexprep(data(1).tag_name,'^v?(.*)$','$1');
        end
        
        function varargout = checkUpdate(obj)
            
            nargoutchk(0,1)
            
            % check validity of version strings & extract fields
            vCell = struct;
            vMat  = struct;
            for tmp = {'Local','Remote'}
                [valid,vCell.(tmp{:})] = obj.validateVersionString(...
                    obj.([tmp{:} 'Version']));
                if ~valid
                    error('%s version string "%s" is invalid.',...
                        tmp{:},obj.([tmp{:} 'Version']))
                end
                vMat.(tmp{:}) = str2double(vCell.(tmp{:})(1:3));
            end
                     
            % compare versions (major, minor and patch number)
            tmp1   = find(vMat.Remote > vMat.Local,1);
            tmp2   = find(vMat.Remote < vMat.Local,1);
            result = ~isempty(tmp1) && (isempty(tmp2) || tmp2>tmp1);
            
            % check pre-release string if necessary
            
            
            if ~result
                % TODO: check pre-release string
            end
            
            % set return value / show result
            if nargout
                varargout{1} = result;
            else
                fprintf('Local version:  %s\n',obj.LocalVersion)
                fprintf('Remote version: %s\n\n',obj.RemoteVersion)
                if result
                    disp('Update available!')
                else
                    disp('You are up to date.')
                end
            end
        end
    end
    
    methods (Static)
        
        function connected = testInternet()
            try
                java.net.InetAddress.getByName('www.github.com');
                connected = true;
            catch
                connected = false;
            end
        end
        
        function [isvalid,components] = validateVersionString(input)
            % validate arguments
            nargoutchk(0,2)
            validateattributes(input,{'char','string'},...
                {'row'},mfilename,'INPUT')
            if isstring(input)
                input = input.char;
            end

            % get components of version string
            % (c.f., https://semver.org/spec/v2.0.0.html)
            components = regexpi(input, ...
                ['^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)' ...
                '(-((0|[1-9]\d*|\d*[a-z-][\da-z-]*)' ...
                '(\.(0|[1-9]\d*|\d*[a-z-][\da-z-]*))*))?' ...
                '(\+([\da-z-]+(?:\.[\da-z-]+)*))?$'], 'once', 'tokens');

            % check validity
            isvalid = ~isempty(components);

            % remove remaining delimiters
            if isvalid && nargout > 1
                components(4:5) = regexprep(components(4:5),'^(-|\+)','');
            end
        end
    end
end
    

% % % compare versions
% % matRemote = verMatrix(strRemote);
% % matLocal  = verMatrix(strLocal);
% % tmp1 = find(matRemote > matLocal,1);
% % tmp2 = find(matRemote < matLocal,1);
% % if ~isempty(tmp1) && (isempty(tmp2) || tmp2>tmp1)
% %     disp('Update available!')
% % else
% %     disp('You are up to date.')
% %     return
% % end
% % 
% % 
% % % char2dec = @(s) base2dec(dec2base(double(s)-96,27)',27);