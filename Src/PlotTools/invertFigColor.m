%invertFigColor will invert black and white colors in a figure. Use this
%function before saving Matlab figures.
%
%  invertFigColor(Gx, Clr)
%
%  INPUT
%    Gx: figure handle
%    Clr: letter of 1x3 RGB matrix of the color of the background
%
%  NOTE
%    Figure colors will be inverted, with the background set to Clr.
%
function invertFigColor(Gx)
if ~strcmpi(class(Gx), 'matlab.ui.Figure')
    error('invertFigColor: Input is not a figure handle');
end

%Invert colors of any annotations
HiddenAnnotAx = findall(Gx, 'Tag', 'scribeOverlay');
setRecursiveColor(HiddenAnnotAx);

%Invert colors of all axes in figure
Axs = findall(Gx, 'Type', 'Axes');
for j = 1:length(Axs)
    setRecursiveColor(Axs(j));
end

%Invert colors of the figure background itself
set(gcf, 'Color', 1 - get(gcf, 'Color'));
set(gcf, 'InvertHardCopy', 'off');

function setRecursiveColor(Ax)
for j = 1:length(Ax)
    Fields = fieldnames(Ax(j));
    ColorLoc = findCellT(Fields, {'Color', 'XColor', 'Ycolor', 'EdgeColor', 'FaceColor', 'CData'}, 'MatchCase', 'any');
    ModeLoc = findCellT(Fields, 'Mode', 'MatchCase', 'any', 'MatchWord', 'partial');
    ColorLoc = setdiff(ColorLoc, ModeLoc);
    ColorLoc(ColorLoc == 0) = [];
    if ~isempty(ColorLoc) && ColorLoc(end) > 0 
        for k = 1:length(ColorLoc)
            CurColor = get(Ax(j), Fields{ColorLoc(k)});
            if ~ischar(CurColor) && ~isempty(CurColor)
                set(Ax(j), Fields{ColorLoc(k)}, 1 - CurColor);
            end
        end
    end

    Cx = get(Ax(j), 'children');
    if ~isempty(Cx)
        setRecursiveColor(Cx)
    end

    TitleLoc = findCellT(Fields, {'Title'});
    if TitleLoc(end) > 0
        Tx = get(Ax(j), 'Title');
        if ~isempty(Tx)
            setRecursiveColor(Tx);
        end
    end
end
