function [ShiftedKValues] = ShiftMaxima(KValues)
    
    S = size(KValues,1);
    [MaxValue, MaxIndex] = max(KValues(:));
    ShiftedKValues = zeros(S,1);
    
    for i=1:S
      
        if (MaxIndex-1+i) <= S
            ShiftedKValues(i) = KValues(MaxIndex-1+i);
        else
            ShiftedKValues(i) = KValues(MaxIndex-S+i-1);
        end
        
    end
    
end