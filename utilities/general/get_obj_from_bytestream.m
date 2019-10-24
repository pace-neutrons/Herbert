function  obj = get_obj_from_bytestream(bytestream,varargin)
% wrapper around system getArrayFromByteStream function which
% recovers a Matlab object from array of bytes, previously obtained using
% getByteStreamFromArray function.
%
% Usage:
%>>obj= get_obj_from_bytestream(bytestream)
%          where bytestream is an array of bytes and the object is
%          recovered from this array
%
%If second function argument is provided, the routine tries to use mex file
%(used in testing/debugging situations)
%
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%

if nargin>1
    obj = byte_stream(bytestream,'Deserialize');
else
    try
        obj= getArrayFromByteStream(bytestream);
    catch
        obj = byte_stream(bytestream,'Deserialize');
    end
end