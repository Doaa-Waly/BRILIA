%parseFileName will take a filename string and parse it into Path, Name,
%and FileExt. This is better than MATLAB's fileparts, which yields
%filepaths that lack the ending slash, or yields filenames without the
%extensions.
%
%  [FilePath, FileName, FileExt] = parseFileName(FullName)
%
%  [FilePath, FileName, FileExt] = parseFileName(FullName, 'ignorefilecheck')
%
%  INPUT
%    FullName: file path and name to be parsed
%    'ignorefilecheck': use this to prevent parseFileName from checking if
%      file exists, especially when file path is not provided in the
%      FullName. This is used mainly for parsing a save file name. Note
%      that without this option, FilePath will return [] if file does not
%      exists. If ignorefilecheck, will return current directly as file
%      path.
%
%  OUTPUT
%    FilePath: File path for the FullName, including end slasshes EX:
%      'C:\Users\User1\PathFolder\'
%    FileName: File name including any extensions, if any 'test.csv'
%    FileExt: File extension only, including the dot. Ex: '.csv'
%
%  EX: 
%    F = 'C:\Users\Desktop\testing.xlsx';
%    [FilePath, FileName, FileExt] = parseFileName(F, 'ignorefilecheck')
%      FilePath =  C:\Users\Desktop\
%      FileName =  testing.xlsx
%      FileExt =  .xlsx
function [FilePath, FileName, FileExt] = parseFileName(FullName, varargin)
%See if you want to check for file existence
CheckFileExists = 'y';
if ~isempty(varargin)
    if strcmpi(varargin{1}, 'ignorefilecheck')
        CheckFileExists = 'n';
    end
end

%Establish defaults
FileName = [];
FileExt = [];

%Case when no file path is given, assume cd is file path
SlashLoc = regexp(FullName, filesep); %Location of fwd or bwd slashes
if isempty(SlashLoc)
    FileName = FullName;
    DotLoc = find(FileName == '.');
    if ~isempty(DotLoc)
        if length(FileName) - DotLoc(end) <= 7 %.xxxx file extension 
            FileExt = FileName(DotLoc(end):end);
        end
    end
    
    %Make sure the file does exist before specifying the file path as cd
    FilePath = [cd filesep]; %Assume FilePath is cd for now
    if ~exist([FilePath FileName], 'file') && CheckFileExists == 'y'
        FilePath = [];
    end
    return
end

%If filepath was given, parse and determine everything
FilePath = FullName(1:SlashLoc(end));
if SlashLoc(end) < length(FullName)
    FileName = FullName(SlashLoc(end)+1:end);
    DotLoc = find(FileName == '.');
    if ~isempty(DotLoc)
        if length(FileName) - DotLoc(end) <= 7 %.xxxx file extension 
            FileExt = FileName(DotLoc(end):end);
        end
    end
    return
end
