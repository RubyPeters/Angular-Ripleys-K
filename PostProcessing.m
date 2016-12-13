%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                   Post processing option 
%                                                         
%             Ruby Peters, King's College London, 2016.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User Definables
MainDirectory=('C:\Users\Desktop\');            %Please enter your directory in which your
                                             ... cropped ROIs and corresponding analysis is stored.
cd(MainDirectory);

CellCentre=[,];                                 %Please enter the centre of your cell in the form
                                             ... [x, y];

Number_of_ROIS=[];                              %Please enter the number of ROIs.                                          
                                         
Shift=1;                                        %1 true, 0 false - Default 1 for fitting the data. 



%% Main
for t=1:Number_of_ROIS
    
SubDirectory=['Region', num2str(t)];
cd(SubDirectory);

FileName=['CentreRegion',num2str(t),'.txt'];
CentreRegion=importdata(FileName);

FileName2=['OutputData',num2str(t),'.txt'];
Region=importdata(FileName2);

Region_=Region(:,2);
AngleBins=Region(:,1);

Vector = CentreRegion-CellCentre;
Norm = sqrt(Vector(1,1)^2+Vector(1,2)^2);
DotProduct = Vector(1,2);
Angle = acos(DotProduct/Norm)*180/pi;
ApproxAngle = round(Angle/5)*5;
Index = ApproxAngle/5;

S = size(Region_,1);ShiftedRegion= zeros(S,1);
    
    for i=1:S
      
        if (Index-1+i) <= S
            ShiftedRegion(i) = Region_(Index-1+i);
        else
            ShiftedRegion(i) = Region_(Index-S+i-1);
        end
        
    end
    
Average=mean(ShiftedRegion);
NormalisedShiftedRegion=[];
NormalisedShiftedRegion=ShiftedRegion/Average;
  
Maximum_after_norm=max(NormalisedShiftedRegion);
Minumum_after_norm=min(NormalisedShiftedRegion);
Amplitude=Maximum_after_norm-Minumum_after_norm;

FileName3=['Shifted Region',num2str(t),'.txt'];
dlmwrite(FileName3, NormalisedShiftedRegion)

FileName4=['Amplitude', num2str(t), '.txt'];
dlmwrite(FileName4, Amplitude)



if Shift==1
    
    [xData, yData] = prepareCurveData( AngleBins, NormalisedShiftedRegion);
    ft = fittype( 'poly8' );
    [fitresult, gof] = fit( xData, yData, ft ); 
    figure
    plot( fitresult, xData, yData );warning('off','all'); xlim([0 355]);
    axis square; box on; xlabel('Angle({\circ})');ylabel('Normalised Shifted Region');
    savefig('Post processing.fig');
    close
      
end

cd(MainDirectory)
end



