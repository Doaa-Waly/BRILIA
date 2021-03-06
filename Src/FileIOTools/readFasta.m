%readFasta will read a fasta file and return 2 cells containing the
%sequence name and the sequence itself. Similar to matlab "fastaread"
%but can handle files with empty line spacers.
%
%  [Header, Seq] = readFasta();
%
%  [Header, Seq] = readFasta(FileName);
%
%  [Header, Seq] = readFasta(FileName, 'SeqRange', Range)
%
%  INPUT
%    FileName: file name of the fasta file. If empty, will ask user to
%      select the file.
%    Range: 2-element integer vector specifying first and last sequence
%      to read.
%
%  OUTPUT
%    Header: Nx1 cell of sequence header information
%    Seq: Nx1 cell of sequences

function [Header, Seq] = readFasta(varargin)
SeqRange = [1 Inf];
RangeOptLoc = strcmpi(varargin, 'seqrange') | strcmpi(varargin, 'blockread');
if any(RangeOptLoc)
    RangeIdx = find(RangeOptLoc) + 1;
    SeqRange = varargin{RangeIdx(1)};
    if length(SeqRange) == 1
        SeqRange = SeqRange * [1 1];
    end
    SeqRange(SeqRange < 1) = 1;
    varargin(RangeIdx(1)-1:end) = [];
end

if isempty(varargin)
    [FileName, FilePath] = uigetfile('*.txt;*.fa*', 'Open FASTA file');
    InputFileName = [FilePath FileName];
elseif exist(varargin{1}, 'file') || exist(fullfile(pwd, varargin{1}), 'file')
    InputFileName = varargin{1};
else
    error('%s: input file not specified correctly.', mfilename);
end

[FID, MSG] = fopen(InputFileName, 'r');
if FID < 0
    error('%s: Could not open FASTA file "%s".\n  %s', mfilename, InputFileName, MSG);
end
Texts = textscan(FID, '%s', 'delimiter', '\n');
Texts = Texts{1};
fclose(FID);

BrackLoc = regexp(Texts, '>', 'once');
Idx = find(~cellfun('isempty', BrackLoc));
SeqRange(2) = min([SeqRange(2) length(Idx)]);

Header = cell(diff(SeqRange) + 1, 1);
Seq = cell(diff(SeqRange) + 1, 1);
k = 1;
for j = SeqRange(1):SeqRange(2)
    Io = Idx(j) + 1;
    if j < length(Idx)
        If = Idx(j+1) - 1;
    else
        If = length(Texts);
    end
    Header{k} = Texts{Idx(j)}(BrackLoc{Idx(j)}+1:end);
    Seq{k} = strrep(strcat(Texts{Io:If}), ' ', '');
    k = k+1;
end
