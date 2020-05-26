classdef intrinsic < handle & matlab.mixin.CustomDisplay

    properties %(Access = private)
        Version         = '1.0.0-alpha1';
        Flags

        h               = [] 	% handles

        DirBase         = fileparts(fileparts(mfilename('fullpath')));
        DirSave
        DirLoad         = [];

        VideoPreview

        Scale           = 0.5
        ...
        and so on and so forth
        (just a test)
