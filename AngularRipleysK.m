%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%               AngularRipleysK - Main analysis code
%                                                         
%             Ruby Peters, King's College London, 2016.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User Inputs

MainDirectory = 'C:\Users\Ruby\Desktop\Kate\011216\Cell 2\'; % Please enter the main directory in which your cropped ROIs are saved.  
cd(MainDirectory);

number_of_regions=[4];                          % Please enter the number of ROIs you have created. 
 
r=200;                                         % Please enter the Radius over which to perform the analysis. Default r=200nm
                                            
LateralCropping = 200;                         % This will crop edges to compensate for edge effects. LateralCropping must be >=r. Default 200 nm. 
                                                
AngleIncrement = 5;                            % Angular increment (in degrees) to perform the analysis. Default = 5 degrees. 

Shift = 1;                                     % 1 for True and 0 for False (depending on if you want to shift H(a) Values - default 1)

%% Main script 
for n=1:number_of_regions

SubDirectory=['Region', num2str(n)];
cd(SubDirectory);

FileName = ['Region',num2str(n),'_crop.txt'];
InputData = importdata(FileName);

OutputData=InputData;
yMax = max(OutputData(:,2));
xMax = max(OutputData(:,1));
AreaData =  xMax*yMax;
CentreRegion=[[(xMax./2) (yMax./2)]];


yRoi = yMax-2*LateralCropping;
xRoi = xMax-2*LateralCropping;
AreaRoi = xRoi*yRoi;

xCoord = OutputData(:,1);
yCoord = OutputData(:,2);
NumberPoints = size(OutputData,1);


Tested_X = [];
Tested_Y = [];

for t = 1:NumberPoints
    
    if xCoord(t)>=LateralCropping && xCoord(t)<=(xRoi+LateralCropping) && yCoord(t)>=LateralCropping && yCoord(t)<=(yRoi+LateralCropping)
        Tested_X = [Tested_X ; xCoord(t)];
        Tested_Y = [Tested_Y ; yCoord(t)];
    end
    
end

for r=200
    
AngleBins = 0:AngleIncrement:(360-AngleIncrement) ; AngleBins=AngleBins';
CumKValues = zeros(size(AngleBins,1),1);
CumShiftedKValues = zeros(size(AngleBins,1),1);
AreaSegment = pi*(r^2)*AngleIncrement/360;

for j = 1:size(Tested_X,1)
        
        x = Tested_X(j);
        y = Tested_Y(j);
       
        r_xCoord = [];
        r_yCoord = [];
        tDistances = [];
          
       for h = 1:(NumberPoints-1)
          
                if h~=j
              
                xVar = xCoord(h);
                yVar = yCoord(h);
                tDistance = sqrt ((xVar-x)^2 + (yVar-y)^2);
                
                if tDistance < r
                    r_xCoord = [r_xCoord ; xVar];
                    r_yCoord = [r_yCoord ; yVar];
                    tDistances = [tDistances ; tDistance];
                end
                
                end
       end
       
       % Calculate angles of each vector with the reference vertical vector
       % of length r
       
       Angles = [];
       NormRef = r;
       
       for k = 1:size(r_xCoord);
           
           DotProduct = (r_yCoord(k)-y)*r;
           Norm = tDistances(k);
           
           % To avoid 'reflecting' the points in the left side of the circumference
           % onto the right one (same value of cosine) we convert from cos
           % to angle taking into account the x-position of each point with
           % respect to the x-position of the reference point
           
           if (r_xCoord(k)-x<=0)
               Angle = 360-(acos((DotProduct/(Norm*NormRef)))*180/pi);
           else
               Angle = acos((DotProduct/(Norm*NormRef)))*180/pi;
           end
           Angles = [Angles ; Angle];
           
       end
       
       KValues = [];
      
       for k = 1:size(AngleBins)
        
           Counter = 0;
           
           for l = 1:size(r_xCoord)
               if (AngleBins(k)<=Angles(l) && (AngleBins(k)+AngleIncrement)>Angles(l))
                   Counter = Counter + 1;
               end
           end
           
           KValue = Counter;
           KValues = [KValues ; KValue];
           
       end
       
       if Shift == 1
           [ShiftedKValues] = ShiftMaxima(KValues);
           CumShiftedKValues = CumShiftedKValues + ShiftedKValues;
       end
       
       CumKValues = CumKValues + KValues;
       
end

AverageKValues = CumKValues/size(Tested_X,1);

if Shift == 1
    AverageShiftedKValues = CumShiftedKValues/size(Tested_X,1);
end


%% Normalisation of Values by comparison with analytical solution of CSR 

NormalisedKValues = 360/AngleIncrement*AreaData/NumberPoints*AverageKValues;

if Shift == 1
    NormalisedShiftedKValues = 360/AngleIncrement*AreaData/NumberPoints*AverageShiftedKValues;
    ShiftedLValues=sqrt(NormalisedShiftedKValues/pi);
    ShiftedHValues=ShiftedLValues-r;
end


%% L and H values

LValues = sqrt(NormalisedKValues/pi);
HValues = LValues-r;

%% Set saving feature

Hvaluesdata = [AngleBins HValues ShiftedHValues];
FileName2 = ['OutputData',num2str(n),'.txt'];
dlmwrite(FileName2,Hvaluesdata); %OutputData will inclue Angluar Bin ranges, H(a) Values and Shifted H(a) values. 


if Shift == 1
    figure
    plot(AngleBins,ShiftedHValues,'-k','Linewidth',1.5);set(gca,'box','on');
    axis('square'); xlabel('Angle ({\circ})'); ylabel('Shifted H Values'); xlim([0 355])
    savefig('Shifted_H_versus_AngleBins.fig')
    close
end


cd(MainDirectory)

end
end
clear