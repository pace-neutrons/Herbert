function instrument = let_instrument(ei, hz5, hz3, slot5_mm, mode, inst_ver)
% Return instrument description for LET
%
%   >> instrument = let_instrument(ei, hz5, hz3, slot_mm, mode, inst_ver)
%
% Input parameters can be scalar or arrays. Array argument(s) result in an
% array of isntrument descriptions, where any scalar arguments are the
% same for all instruments.
%
% Input:
% ------
%   ei          Incident energy (meV)
%
%   hz5         Chopper 5  frequency
%
%   hz3         Chopper 3 frequency
%
%   slot5_mm    Full width of the chopper 5 slot (in mm)
%               Permissible values depend on the instrument version (see below)
%                   inst_ver = 1    10mm
%                   inst_ver = 2    15mm, 20mm, 31mm
%                   
%   mode        Resolution mode: determines the frequency of chopper 1
%                   mode = 1    "high resolution" (hz1 = 0.5*hz5)
%                   mode = 2    "high flux"       (hz1 = 0.5*hz3)
%
%   inst_ver    Instrument version:
%                   inst_ver = 1    LET with double funnel snout at chopper 5
%                                   Covers period up to Autumn 2016
%                   inst_ver = 2    LET with single focussing final guide
%                                   section. Cover the period from Autumn 2017


% Created by T.G.Perring
%  Data from Rob Bewley's Matlab program Multi_rep_new_LET.m, which was given to
% TGP by RIB on 20 Dec 2016.
%  Divergence data from McStas simulations performed by RIB and sent to TGP 
% on 20 DEc 2016.


% Check input arguments are valid
% -------------------------------
if ~(isnumeric(ei) && all(ei(:))>0)
    error('Incident energy must be greater than zero')
end

if ~(isnumeric(hz5) && all(hz5(:))>0)
    error('Chopper 5 frequency must be greater than zero')
end

if ~(isnumeric(hz3) && all(hz3(:))>0)
    error('Chopper 3 frequency must be greater than zero')
end

if ~(isnumeric(slot5_mm) && all(slot5_mm(:))>0)
    error('Slot width (mm) must be greater than zero')
end

if ~(isnumeric(mode) && all(mode(:)==1 | mode(:)==2))
    error('Instrument running mode must be 1 or 2')
end

if ~(isnumeric(inst_ver) && all(inst_ver(:)==1 | inst_ver(:)==2))
    error('Instrument version must be 1 or 2')
end

% Expand arguments if necessary
[ei, hz5, hz3, slot5_mm, mode, inst_ver] = expand_args...
    (ei, hz5, hz3, slot5_mm, mode, inst_ver);
n_inst = numel(ei);

% Check values for slot width
for i=1:n_inst
    if inst_ver(i)==1
        if slot5_mm(i)~=10
            error('With instrument version 1, slot_mm can only be equal to 10mm')
        end
    else
        if ~(slot5_mm(i)==15 || slot5_mm(i)==20 || slot5_mm(i)==31)
            error('With instrument version 2, slot_mm can only be equal to 15mm, 20mm or 31mm')
        end
    end
end

% Get look up tables for divergences
data_dir = fullfile(fileparts(mfilename('fullpath')),'private');
div.ver1_h = load(fullfile(data_dir,'LET_ver1_horiz_div.mat'));
div.ver1_v = load(fullfile(data_dir,'LET_ver1_vert_div.mat'));
div.ver2_h = load(fullfile(data_dir,'LET_ver2_horiz_div.mat'));
div.ver2_v = load(fullfile(data_dir,'LET_ver2_vert_div.mat'));

% Construct instrument(s)
instrument = LET_instrument_single (ei(1), hz5(1), hz3(1), slot5_mm(1), mode(1), inst_ver(1), div);
if n_inst>1
    instrument = repmat(instrument,size(ei));
    for i=2:n_inst
        instrument(i) = LET_instrument_single (ei(i), hz5(i), hz3(i), slot5_mm(i), mode(i), inst_ver(i), div);
    end
end


%--------------------------------------------------------------------------------------------------
function instrument = LET_instrument_single (ei, hz5, hz3, slot5_mm, mode, inst_ver, div)

% Instrument parameters from Rob Bewley's code Multi_rep_new_LET.m
Lmch = 15.67;   % mod to chop 5 distance in m. mod is taken at chop 1
Lchs = 1.5;     % distance from chop 5 to sample
mod_sam = 25.0; % mod to sample distance

x0 = mod_sam - Lchs;
x1 = Lchs;
xCh1toS = Lmch + Lchs;
xCh5toS = Lchs;


% -----------------------------------------------------------------------------
% Moderator
% -----------------------------------------------------------------------------
%   distance        Distance from sample (m) (+ve, against the usual convention)
%   angle           Angle of normal to incident beam (deg)
%                  (positive if normal is anticlockwise from incident beam)
%   pulse_model     Model for pulse shape (e.g. 'ikcarp')
%   pp              Parameters for the pulse shape model (array; length depends on pulse_model)

distance=x0+x1;
angle=0.0;                      % *** In absence of information; guide loses true value anyway
pulse_model='ikcarp';
pp=[77.3/sqrt(ei)+1.944,0,0];   % *** Based on RIB line of code: fwhm_mod=29*(Lami)+6.6;
                                % *** and fwhh = 3.394680670846503*tau for chisqr function
    
moderator=IX_moderator(distance,angle,pulse_model,pp);

% -----------------------------------------------------------------------------
% Divergence
% -----------------------------------------------------------------------------
%   angle           Vector of divergences (radians)
%   profile         Vector with profile. The first and last elements must be
%                  zero, and all other elements must be >= 0. Does not need to be
%                  normalised.

lam = sqrt(81.80420126/ei);
if inst_ver==1
    horiz_div = get_divergence (div.ver1_h, lam);
    vert_div  = get_divergence (div.ver1_v, lam);
elseif inst_ver==2
    horiz_div = get_divergence (div.ver2_h, lam);
    vert_div  = get_divergence (div.ver2_v, lam);
else
    error('Unrecognised instrument version')
end



% -----------------------------------------------------------------------------
% Disk choppers
% -----------------------------------------------------------------------------
%   name            Name of the chopper (e.g. 'chopper_5')
%   distance        Distance from sample (m) (+ve if upstream of sample, against the usual convention)
%   frequency       Frequency of rotation of each disk (Hz)
%   radius          Radius of chopper body (m)
%   slot_width      Slit width (m)

% chopper_1
if mode==1      % high resolution mode
    hz1 = 0.5*hz5;
elseif mode==2  % high flux mode
    hz1 = 0.5*hz3;
else
    error('Unrecognised instrument running mode')
end

slot1_mm = 40;      % slot width mm
radius1_mm = 280;   % chopper radius mm

chop1=IX_doubledisk_chopper('chopper_1', xCh1toS, hz1, radius1_mm/1000, slot1_mm/1000);

% chopper_5
radius5_mm = 280;   % chopper radius mm
chop5=IX_doubledisk_chopper('chopper_5', xCh5toS, hz5, radius5_mm/1000, slot5_mm/1000);


% -----------------------------------------------------------------------------
% Build instrument
% -----------------------------------------------------------------------------
instrument.moderator = moderator;
instrument.chop_shape = chop1;
instrument.chop_mono = chop5;
instrument.horiz_div = horiz_div;
instrument.vert_div  = vert_div;
