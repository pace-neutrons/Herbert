function [S,Err,en,this] =get_signal(this,varargin)
% Method returns signal (S,Err and en) from previously defined data loader
% 
% usage: 
%>> [S,Err,en,this] ==get_signal(this,[file_name])
%
%Inputs:
% this     -- initiated instance of the run data class;
% filename -- optional parameter allowing to redefine the input file for
% the data loader
%
%
%
% $Revision$ ($Date$)
%

if exist('file_name','var')||isempty(this.S)
    [this.S,this.ERR,this.en,this.loader_stor] = load_data(this.loader_stor,varargin{:});    
    if max(this.en)>=this.efix
        error('RUN_DATA:get_signal','maximal energy scale %d exceed maximal input energy %d',max(this.en),this.efix);
    end
end

S = this.S;
Err=this.ERR;
en =this.en;

