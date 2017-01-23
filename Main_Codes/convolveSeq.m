%convolveSeq will align sequence SeqA and SeqB using the BRILIA alignment
%protocol. Consecutive matches add C^2 score and consecutive mismatches
%subtract M^2 score, where C and M is the length of each contiguous
%segment. If AllowedMiss is specified, then C segments can be elongated
%only if there is a 1-letter miss, and if the number of AllowedMiss has not
%been reached, going left to right. More information is provided in the
%reference for BRILIA.
%
%  Score = convolveSeq(SeqA, SeqB)
%
%  [Score, Alignment] = convolveSeq(SeqA, SeqB,)
%
%  [Score, Alignment, StartAt] = convolveSeq(SeqA, SeqB,)
%
%  [Score, Alignment, StartAt, MatchAt] = convolveSeq(SeqA, SeqB,)
%
%  [...] = convolveSeq(SeqA, SeqB, Param1, Value1, ...)
%
%  [...] = convolveSeq(SeqA, SeqB, P) where P is an input structure
%  
%  INPUTS
%    SeqA: Character sequence. X = wildcard match. Z = do not match.
%    SeqB: Character sequence. X = wildcard match. Z = do not match.
%
%  INPUTS (Param, [Value])
%    AllowedMiss [Integer >= 0]: 
%      How many letter, going left to right, can you miss to elongate a C
%      segment.
%    Alphabet ['nt','aa','any']
%      Specify if it's a DNA/RNA or Amino Acid seq or any char. Used to
%      relabel ambiguous characters to 'X' wildcard letter.
%    TrimSide ['none','left','right','both']
%      Will remove seq matches from the direction specified to increase the
%      alignment quality near edges.
%    PenaltySide ['none','left','right']
%      Will reduce alignment score if the left or right portion of SeqA
%      overhangs SeqB and is unused. Penalty is (unused nt)^2.
%    PreferSide ['none','left','right']
%      If a tie alignment is found, will favor the alignment closers to
%      this side of SeqA.
%    CheckSeq ['no','yes']
%      If you think there is an ambiguous character in sequence, remove it,
%      then set to 'no' as convolve seq will attempt replace with wildcard.
%      HINT: better to remove ambiguous character and set to 'X' BEFORE
%      running this.
%    ExactMatch ['no','yes']
%      If SeqA and SeqB are same lengths and you want to do a simple,
%      direct alignment, then use 'yes'.
%    
%  INPUTS (Structure)
%    For aligning a lot of sequences, use the structure-format input, as
%    this saves time with input checking. Must be correctly made, since no
%    error checking is done at this point.
%         P.AllowedMiss = 0;
%         P.Alphabet = 'nt';
%         P.TrimSide = 'left';
%         P.PreferSide = 'right';
%         P.CheckSeq = 'yes';
%         P.ExactMatch = 'no';
%         P.DiagIdx = [];
%         >> Score = convolveSeq(SeqA,SeqB,P)
%
%  OUTPUTS
%    Score = 2x1 matrix, Score(1) is the # of hits, and Score(2) is the
%      aligment score of BRILIA.
%    Alignment = 3xM char matrix showing the alignment results of SeqA and
%      SeqB. '|' in the 2nd char row marks locations of matches, while '-'
%      in the 1st and 3rd row are unmatched letters.
%    StartAt = 2x1 matrix, StartAt(1) is always 1 the SeqA start, and
%      StartAt(2) is the SeqB start relative to the nth letter of SeqA. 
%      EX: if StartAt(2) = 3, then SeqB aligns with A if its 1st letter
%      start below the 3rd letter of SeqB. If StartAt(2) = -3, then the 1st
%      letter of SeqB start left of SeqA's 1st letter by 3 letters (missing
%      3 letters).
%    MatchAt = 2x1 matrix showing the 1st and last location of the '|' in
%      the Alignment char matrix.
%
%--------------------------------------------------------------------------
%  EXAMPLES
%    Case1) "TrimSide" edge cleaning
%      SeqA = 'TAATAATTAAT'
%      SeqB = 'TCCTAATTGGT'
%      [Score, Alignment, StartAt, MatchAt] = convolveSeq(SeqA,SeqB)
%      Score =
%            7
%           19
%      Alignment =
%         TAATAATTAAT
%         |  |||||  |
%         TCCTAATTGGT
%      StartAt =
%            1
%            1
%      MatchAt =
%            1
%           11
%
%      [Score, Alignment] = convolveSeq(SeqA,SeqB,'TrimSide','left')
%       Alignment =
%         TAATAATTAAT
%            |||||  |
%         TCCTAATTGGT
%
%      [Score, Alignment] = convolveSeq(SeqA,SeqB,'TrimSide','right')
%       Alignment =
%         TAATAATTAAT
%         |  |||||   
%         TCCTAATTGGT
%
%      [Score, Alignment] = convolveSeq(SeqA,SeqB,'TrimSide','both')
%       Alignment =
%         TAATAATTAAT
%            |||||   
%         TCCTAATTGGT
%
%    Case2) "PreferSide" tie-breaking
%      SeqA = 'AAAA'
%      SeqB = 'CAAAATTAAAATTAAAAC'
%      [~, Alignment] = convolveSeq(SeqA,SeqB,'PreferSide','left')
%       Alignment =
%         -AAAA-------------
%          ||||             
%         CAAAATTAAAATTAAAAC
%
%      [~, Alignment] = convolveSeq(SeqB,SeqA,'PreferSide','left')
%         CAAAATTAAAATTAAAAC
%          ||||             
%         -AAAA------------- 
%
%      [~, Alignment] = convolveSeq(SeqA,SeqB,'PreferSide','right')
%       Alignment =
%         -------------AAAA-
%                      |||| 
%         CAAAATTAAAATTAAAAC
%
%      [~, Alignment] = convolveSeq(SeqA,SeqB,'PreferSide','none')
%       Alignment =
%         -------AAAA-------
%                ||||       
%         CAAAATTAAAATTAAAAC
%
%    Case3) Wildcard matching and exact matching
%      SeqA = 'CGAAXCAA'
%      SeqB = 'ACGAACGA'
%      [~, Alignment] = convolveSeq(SeqA,SeqB,'ExactMatch','no')
%       Alignment =
%         -CGAAXCAA
%          ||||| |  
%         ACGAACGA-
%
%      [~, Alignment] = convolveSeq(SeqA,SeqB,'ExactMatch','yes')
%       Alignment =
%         CGAAXCAA
%            ||| |
%         ACGAACGA
%
%    Case4) AllowedMiss scoring changes
%      SeqA = 'ACGTGGTA'
%      SeqB = 'ACATGATA'    
%      [Score, Alignment] = convolveSeq(SeqA,SeqB,'ExactMatch','yes','AllowedMiss',0)
%       Score =
%           6
%          10
%       Alignment =
%         ACGTGGTA
%         || || ||
%         ACATGATA
%
%      Score = convolveSeq(SeqA,SeqB,'ExactMatch','yes','AllowedMiss',1)
%        Score =
%            6
%           19
%
%  See also makeDiagonalSeq, calcAlignScore, trimMatchResults
function varargout = convolveSeq(SeqA,SeqB,varargin)
%--------------------------------------------------------------------------
%Input parsing

if isempty(varargin) %Use defaults
    AllowedMiss = 0;
    Alphabet = 'nt';
    TrimSide = 'none';
    PreferSide = 'none';
    PenaltySide = 'none';
    ExactMatch = 'no';
    CheckSeq = 'no';
    DiagIdx = [];
else %User specified changes
    if ~isstruct(varargin{1})
        %Need to parse from scrap
        P = inputParser;
        addParameter(P,'AllowedMiss',0,@isnumeric);
        addParameter(P,'Alphabet','nt',@(x) ischar(x) && ismember(lower(x),{'nt','aa','any'}));
        addParameter(P,'TrimSide','none',@(x) ischar(x) && ismember(lower(x),{'none','left','right','both'}));
        addParameter(P,'PenaltySide','none',@(x) ischar(x) && ismember(lower(x),{'none','left','right','both'}));
        addParameter(P,'PreferSide','none',@(x) ischar(x) && ismember(lower(x),{'none','left','right'}));
        addParameter(P,'ExactMatch','no',@(x) ischar(x) && ismember(lower(x),{'yes','no'}));
        addParameter(P,'CheckSeq','no',@(x) ischar(x) && ismember(lower(x),{'yes','no'}));
        addParameter(P,'DiagIdx',[],@isnumeric); %Used only to speed up convolve seq.
        parse(P,varargin{:});

        AllowedMiss = P.Results.AllowedMiss;
        Alphabet = lower(P.Results.Alphabet);
        TrimSide = lower(P.Results.TrimSide);
        PenaltySide = lower(P.Results.PenaltySide);
        PreferSide = lower(P.Results.PreferSide);
        CheckSeq = lower(P.Results.CheckSeq);
        ExactMatch = P.Results.ExactMatch;
        DiagIdx = P.Results.DiagIdx;
    else
        %Advance user specified exact fields and values. 
        %No error checking done! 
        P = varargin{1};
        AllowedMiss = P.AllowedMiss;
        Alphabet = P.Alphabet;
        TrimSide = P.TrimSide;
        PenaltySide = P.PenaltySide;
        PreferSide = P.PreferSide;
        ExactMatch = P.ExactMatch;
        CheckSeq = P.CheckSeq;
        DiagIdx = P.DiagIdx;
    end
end

%--------------------------------------------------------------------------
%Input checking

%Make sure SeqA and SeqB are 1xM char
if iscell(SeqA)
    SeqA = SeqA{1};
    if size(SeqA,1) > 1
        disp('Warning: SeqA should a 1x1 cell or 1xN char. Taking first one only');
    end
end
if iscell(SeqB)
    SeqB = SeqB{1};
    if size(SeqB,1) > 1
        disp('Warning: SeqB should a 1x1 cell or 1xN char. Taking first one only');
    end
end

%Make sure SeqA and SeqB are all upper case
SeqA = upper(SeqA);
SeqB = upper(SeqB);

%Check seq for ambiguous char, replacing them with X (HINT: Better to ensure no ambig char before convolveSeq)
if strcmpi(CheckSeq(1),'n')
    %Identify what are bad letters
    switch Alphabet
        case 'nt'
            BadPattern = '[^ACGTUX]';
        case 'aa'
            BadPattern = ['[^' int2aa(1:20) 'X]'];
        otherwise
            BadPattern = '';
    end

    %Convert ambiguous characters to X.
    BadLoc1 = regexp(SeqA,BadPattern);
    SeqA(BadLoc1) = 'X';
    BadLoc2 = regexp(SeqB,BadPattern);
    SeqB(BadLoc2) = 'X';
end

%--------------------------------------------------------------------------
%Alignment for Exact Match case

if strcmpi(ExactMatch(1),'y')
    %Check to make sure SeqA and SeqB are the same lengths.
    if length(SeqA) ~= length(SeqB)
        error('Error: SeqA and SeqB must be of same length for exact match.');
    end
    
    AnyMatchIdx = (SeqA == 'X') | (SeqB == 'X'); %Keep track of wildcard matches
    MatchResults = (SeqA == SeqB);
    MatchResults(AnyMatchIdx) = 1;

    %Trim match results, which helps with poor end matches.
    if ~strcmpi(TrimSide,'none');
        GoodIdx = ones(1,length(SeqA),'logical'); %Forces score on all GoodIdx locations
        [MatchResults,TrimIdx] = trimMatchResults(MatchResults,TrimSide);
        GoodIdx(TrimIdx) = 0;
    else
        GoodIdx = []; %Forces score on only first to last match locations
    end

    %Consider implementing ins/del corrector here--------------------------

    %Find the best alignments
    AlignScores = calcAlignScore(MatchResults,AllowedMiss,GoodIdx);
    
    %Perform output calculations on a need basis
    if nargout >= 1 %Return the match ct and score
        varargout{1} = [sum(MatchResults); AlignScores];
        if nargout >=2 %Return alignment
            MatchPat = repmat(' ',1,length(SeqA));
            MatchPat(MatchResults) = '|';
            varargout{2} = [SeqA; MatchPat; SeqB];
            if nargout >= 3 %Return start locs'
                varargout{3} = [1; 1];
                if nargout >= 4 %Return match locs
                    MatchLoc = find(MatchPat == '|');
                    if isempty(MatchLoc)
                        MatchLoc = 0;
                    end
                    varargout{4} = [MatchLoc(1); MatchLoc(end)];
                end
            end
        end
    end
    
    return
end

%--------------------------------------------------------------------------
%Alignment for General case

%Perform pairwise comparison (Delay: 0.6s delay)
[SeqTA,SeqTB,GoodIdx] = makeDiagonalSeq(SeqA,SeqB,DiagIdx);
AnyMatchIdx = SeqTA == 'X' | SeqTB == 'X'; %Keep track of wildcard matches
MatchResults = (SeqTA == SeqTB);
MatchResults(AnyMatchIdx & GoodIdx) = 1;

%Calculate the penalty of not matching left or right side of SeqA
SidePenalty = zeros(size(MatchResults,1),1);
if strcmpi(PenaltySide,'right') %Any unmatched sequence right of SeqA penalizes points!
    SidePenalty(end-length(SeqA)+2:end) = [1:1:length(SeqA)-1].^2;
elseif strcmpi(PenaltySide,'left') %Any unmatched sequence left of SeqA penalizes points!
    SidePenalty(1:length(SeqA)-1) = [length(SeqA)-1:-1:1].^2;
end

%Pick the top 5 unique positives scores to pursue to speed up scoring.
MatchSum = sum(MatchResults,2).^2 - sum((~MatchResults & GoodIdx),2).^2 - SidePenalty; %Should give you maximum score possible.
[MatchSum,MatchIdx] = sort(MatchSum,'descend');
q = 1;
for k = 1:size(MatchSum,1)-1;
    if MatchSum(k) ~= MatchSum(k+1)
        q = q + 1;
    end
    if q > 5
        break
    end
end
if isempty(k); k = 1; end
MatchResults = MatchResults(MatchIdx(1:k),:);
GoodIdx = GoodIdx(MatchIdx(1:k),:);

%----Consider implementing ins/del corrector here--------------------------

%Trim match results to ensure you get the best align score.
if ~strcmpi(TrimSide,'none');
    [MatchResults,TrimIdx] = trimMatchResults(MatchResults,TrimSide);
    GoodIdx(TrimIdx) = 0;
else
    GoodIdx = [];
end

%Find the best alignments (DELAY: 1.3s for all check, 0.1s for top 5 check);
AlignScores = calcAlignScore(MatchResults,AllowedMiss,GoodIdx); %This makes it slower, due to nonlinear scoring function. Linear score function is 2x faster.
BestScore = max(AlignScores);
BestScoreLoc = find(AlignScores == BestScore);

%If more than 1 best scores, break tie by PreferSide.
if length(BestScoreLoc) > 1 
    if strcmpi(PreferSide,'left')
        if length(SeqA) > length(SeqB)
            GetIdx = length(BestScoreLoc);
        else
            GetIdx = 1;
        end
    elseif strcmpi(PreferSide,'right')
        if length(SeqA) > length(SeqB)
            GetIdx = 1;
        else
            GetIdx = length(BestScoreLoc);
        end
    else
        GetIdx = round(length(BestScoreLoc)/2);
    end
    BestScoreLoc = BestScoreLoc(GetIdx);
end

%Get the actual location of the full-length MatchResults, which is used to
%calculate the alignment positions later
BestMatchLoc = MatchIdx(BestScoreLoc);
BestMatch = MatchResults(BestScoreLoc,:);

%Perform output calculations on a need basis
if nargout >= 1 %Return the match ct and score
    varargout{1} = [sum(BestMatch); BestScore];

    if nargout >= 2 %Return the alignment
        %Now determine start and ends for alignments.
        BleftPad = length(SeqA) - BestMatchLoc; %How many B left pad
        BleftTrim = 0; %How many B left trim
        if BleftPad < 0
            BleftTrim = abs(BleftPad); 
            BleftPad = 0;
        end
        
        BrightTrim = length(SeqB) - BestMatchLoc; %How many B right trim
        if BrightTrim < 0
            BrightTrim = 0;
        end

        %Make the alignment 3xN char array
        TotalLen = BleftTrim + BrightTrim + length(SeqA);
        Alignment = repmat(['-';' ';'-'],1,TotalLen);
        MatchPat = repmat(' ',1,length(BestMatch));
        MatchPat(BestMatch) = '|';
        Alignment(2,BleftTrim+1:BleftTrim+length(BestMatch)) = MatchPat;

        %Determine the SeqA and SeqB alignment locations
        SeqAstart = 1; %Always 1, the anchor point
        SeqBstart = BleftPad - BleftTrim; %Negative value is how many nts SeqB is not overlapping with SeqA, left side. Marks where SeqB begins relative to SeqA.
        if SeqBstart >= 0
            SeqBstart = SeqBstart + 1; %Ensure always 1, but no 0.
        end

        if SeqBstart < 0
            Alignment(1,abs(SeqBstart)+1:abs(SeqBstart)+1+length(SeqA)-1) = SeqA;
            Alignment(3,1:1+length(SeqB)-1) = SeqB;
        else
            Alignment(1,SeqAstart:SeqAstart+length(SeqA)-1) = SeqA;
            Alignment(3,SeqBstart:SeqBstart+length(SeqB)-1) = SeqB;
        end
        varargout{2} = Alignment;
        
        if nargout >= 3 %Return the StartAt info
            varargout{3} = [SeqAstart; SeqBstart];
            
            if nargout >= 4 %Return the MatchAt info
                MatchLoc = find(Alignment(2,:) == '|');
                if isempty(MatchLoc)
                    varargout{4} = [0;0];
                else
                    varargout{4} = [MatchLoc(1); MatchLoc(end)];
                end
            end
        end
    end
end