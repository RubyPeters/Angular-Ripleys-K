function [ShiftedKValues] = ShiftMaxima(KValues)
    
    [~, MaxIndex] = max(KValues(:));
    ShiftedKValues = circshift(KValues, -(MaxIndex-1));
end