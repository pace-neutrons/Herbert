function [table,t_av,ind]=buffered_sampling_table(moderator_in,ei_in,varargin)
% Return lookup table for array of moderator objects
%
%   >> table = buffered_sampling_table (moderator, ei)
%   >> table = buffered_sampling_table (moderator, ei, npnt)
%   >> table = buffered_sampling_table (...,opt)
%
% Input:
% ------
%   moderator   Array of IX_moderator objects (need not be unique)
% 
%   ei          Array of corresponding incident energies
%
%   npnt        Number of sampling points for the table. Uses default if not given.
%              The default is that in the lookup table if it is read, otherwise it is
%              the default in the lookup table method.
%               If the number is different to that in the stored lookup table,
%              if read, the stored lookup table will be purged.
%
%   opt         Option:
%                   'purge'     Clear file buffer prior to writing new entries
%                              (will be deleted even if no new entry will be written)
%
%                   'nocheck'   Do not check to see if the stored lookup table
%                              holds the data, regardless of the default threshold
%                              for the number of moderator entries for checking
%                              the file is exceeded. Any stored lookup will not be
%                              added to.
%
%                   'check'     Force a check, even if the default threshold
%                              is not exceeded. If additional lookup entries
%                              have to be created, they will be added to the
%                              stored lookup.
%                              
%
% Output:
% -------
%   table       Lookup table of unique moderator entries, size=[npnt,nmod]
%              where npnt=number of points in lookup table, nmod=number of
%              unique moderator entries. Elements are time in reduced units.
%              Use the look-up table to convert a random number from uniform
%              distribution in the range 0 to 1 into reduced time deviation
%              0 <= t_red <= 1. Convert to true time using the equation
%              t = t_av * (t_red/(1-t_red))
%
%   t_av        First moment of time, size=[1,nmod] (microseconds)
%
%   ind         Index into the lookup table: ind(i) is the column for moderator(i)
%              ind is a column vector.
%
% Note:
% - If the number of moderator objects is less than a critical value, they
%   will be computed rather checked to see if they are in the stored table
%   in order to save the overheads of checking.
% - The size of the lookup table is restricted to a certain maximum size.
%   Earlier entries will be deleted if new ones have to be added. THe lookup
%   table will always have the length of the number of unique entries in the
%   most recent call, as it is assumed that this is the mostlikely next occasion
%   the function will be called for again.


nm_crit=1;      % if number of moderators is less than or equal to this, simply compute
nm_max=1000;    % Maximum number of moderator lookup tables that can be stored on disk
filename=fullfile(tempdir,'IX_moderator_store.mat');

[moderator,ei,im,ind]=unique_mod_ei(moderator_in,ei_in);
moderator=moderator(:); % ensure column vector
ei=ei(:);               % ensure column vector
ind=ind(:);             % ensure column vector
nm=numel(moderator);
if nm<=nm_crit
    check_store=false;
else
    check_store=true;
end

% Strip off option
if nargin>2 && ischar(varargin{end})
    opt=varargin{end};
    if strcmpi(opt,'purge')
        [ok,mess]=delete_store(filename);
        if ~ok, warning(mess), end
    elseif strcmpi(opt,'check')
        check_store=true;
    elseif strcmpi(opt,'nocheck')
        check_store=false;
    else
        error('Unrecognised options')
    end
    narg=numel(varargin)-1;
else
    narg=numel(varargin);
end

% Check if number of points is given
if narg==1
    npnt=varargin{1};
else
    npnt=[];    % signifies use default
end

% Fill lookup table, creating or adding entries for the stored lookup file
if check_store
    [ok,mess,moderator0,ei0,table0,t_av0]=read_store(filename);   % if file does not exist, then ok=true but moderator0 is empty
    if ok && ~isempty(moderator0) && (isempty(npnt)||npnt==size(table0,1))
        % Look for entries in the lookup table
        [ix,iv]=array_filter_mod_ei(moderator,ei,moderator0,ei0);
        npnt0=size(table0,1);
        if numel(ix)==0         % no stored entries for the input moderators
            [table,t_av]=fill_table(moderator,ei,npnt0);
            [ok,mess]=write_store(filename,moderator,ei,table,t_av,...
                                            moderator0,ei0,table0,t_av0,nm_max);
            if ~ok, warning(mess), end
        elseif numel(ix)==nm    % all entries previously stored
            table=table0(:,iv);
            t_av=t_av0(iv);
        else
            new=true(nm,1); new(ix)=false;
            [table_new,t_av_new]=fill_table(moderator(new),ei(new),npnt0);
            table=zeros(npnt0,nm);
            table(:,new)=table_new;
            table(:,ix)=table0(:,iv);
            t_av=zeros(1,nm);
            t_av(new)=t_av_new;
            t_av(ix)=t_av0(iv);
            [ok,mess]=write_store(filename,moderator(new),ei(new),table_new,t_av_new,...
                                            moderator0,ei0,table0,t_av0,nm_max);
            if ~ok, warning(mess), end
        end
    else
        % Problem reading the store, or it doesn't exist, or the number of points is different. Create with new values if can.
        if ~ok, warning(mess), end
        [table,t_av]=fill_table(moderator,ei,npnt);
        [ok,mess]=write_store(filename,moderator,ei,table,t_av);
        if ~ok, warning(mess), end
    end
else
    [table,t_av]=fill_table(moderator,ei,npnt);
end


%==================================================================================================
function [moderator_sort,ei_sort,m,n]=unique_mod_ei(moderator, ei, varargin)
% Joint sorting of moderator and incident energy as if they were one object

S=catstruct(struct_special(moderator(:)),struct('ei',num2cell(ei(:))));
[sortedS,m,n] = uniqueNestedSortStruct(S,varargin{:});
moderator_sort=moderator(m);
ei_sort=ei(m);


%--------------------------------------------------------------------------------------------------
function [ind,indv]=array_filter_mod_ei(moderator,ei,moderator0,ei0,varargin)
% Bespoke version of array_filter treating moderator and incident energy as if they were one object

S =catstruct(struct_special(moderator(:)) ,struct('ei',num2cell(ei(:))));
S0=catstruct(struct_special(moderator0(:)),struct('ei',num2cell(ei0(:))));
[ind,indv]=array_filter(S,S0,varargin{:});


%==================================================================================================
function [table,t_av]=fill_table(moderator,ei,npnt)
nm=numel(moderator);
t_av=zeros(1,nm);
if isempty(npnt)
    [table,t_av(1)]=sampling_table(moderator(1),ei(1));   % column vector
    if nm>1
        table=repmat(table,[1,nm]);
        npnt_def=size(table,1);
        for i=2:nm
            [table(:,i),t_av(i)]=sampling_table(moderator(i),ei(i),npnt_def);
        end
    end
else
    table=zeros(npnt,nm);
    for i=1:nm
        [table(:,i),t_av(i)]=sampling_table(moderator(i),ei(i),npnt);
    end
end

%==================================================================================================
function [ok,mess,moderator_store,ei_store,table_store,t_av_store]=read_store(filename)
% Read stored moderator lookup table
% ok=true if file does not exist

if exist(filename,'file')
    disp('Reading stored moderator lookup table...')
    try
        load(filename,'-mat');
        ok=true;
        mess='';
    catch
        ok=false;
        mess='Unable to read moderator lookup table file';
        moderator_store=[];
        ei_store=[];
        table_store=[];
        t_av_store=[];
    end
else
    ok=true;
    mess='';
    moderator_store=[];
    ei_store=[];
    table_store=[];
    t_av_store=[];
end


%--------------------------------------------------------------------------------------------------
function [ok,mess]=write_store(filename,moderator,ei,table,t_av,moderator0,ei0,table0,t_av0,nf_max)
% Write moderator lookup table up to a maximum number of entries
% Always write the first entry; then add as many of the second as possible

if nargin==5
    moderator_store=moderator;
    ei_store=ei;
    table_store=table;
    t_av_store=t_av;
else
    nf=size(moderator,1);
    nf0=size(moderator0,1);
    if nf>=nf_max
        moderator_store=moderator;
        ei_store=ei;
        table_store=table;
        t_av_store=t_av;
    elseif nf0>nf_max-nf
        moderator_store=[moderator;moderator0(1:nf_max-nf)];
        ei_store=[ei;ei0(1:nf_max-nf)];
        table_store=[table,table0(:,1:nf_max-nf)];
        t_av_store=[t_av,t_av0(1:nf_max-nf)];
    else
        moderator_store=[moderator;moderator0];
        ei_store=[ei;ei0];
        table_store=[table,table0];
        t_av_store=[t_av,t_av0];
    end
end

try
    disp('Writing moderator lookup table to file store...')
    save(filename,'moderator_store','ei_store','table_store','t_av_store','-mat')
    ok=true;
    mess='';
catch
    ok=false;
    mess='Error writing moderator lookup table file';
end


%--------------------------------------------------------------------------------------------------
function [ok,mess]=delete_store(filename)
% Read stored moderator lookup table

if exist(filename,'file')
    try
        disp('Deleting stored moderator lookup table...')
        delete(filename)
        ok=true;
        mess='';
    catch
        ok=false;
        mess='Unable to delete moderator lookup table file';
    end
else
    ok=true;
    mess='';
end
