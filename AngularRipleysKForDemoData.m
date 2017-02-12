%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%               AngularRipleysK - Main analysis code
%
%             Ruby Peters, King's College London, 2016.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User Inputs
clear

MainDirectory = '/Users/user/Documents/work/Angular-Ripleys-K/';      % Please enter the main directory in which your cropped ROIs are saved.
cd(MainDirectory);

r=200;                                         % Please enter the Radius over which to perform the analysis. Default r=200nm

LateralCropping = 200;                         % This will crop edges to compensate for edge effects. LateralCropping must be >=r. Default 200 nm.

AngleIncrement = 5;                            % Angular increment (in degrees) to perform the analysis. Default = 5 degrees.

Shift = 1;                                     % 1 for True and 0 for False (depending on if you want to shift H(a) Values - default 1)

%% Main script


FileName = ['data.txt'];
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
        
        
%         
        r_xCoord = xCoord;
        r_yCoord = yCoord;
        tDistances = sqrt ((r_xCoord-x).^2 + (r_yCoord-y).^2);
        
        r_xCoord(j) = [];
        r_yCoord(j) = [];
        tDistances(j) = [];
        
        
        bad_inds = tDistances >= r;
        r_xCoord(bad_inds) = [];
        r_yCoord(bad_inds) = [];
        tDistances(bad_inds) = [];
        
        
        % Calculate angles of each vector with the reference vertical vector
        % of length r
        
        
        NormRef = r;
        
        DotProduct = (r_yCoord-y)*r;
        Norm = tDistances;
        Angles = acos((DotProduct./(Norm*NormRef)))*180/pi;
        neg_inds = r_xCoord-x<=0;
        Angles(neg_inds) = 360-Angles(neg_inds);
        
        
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
    FileName2 = ['OutputData.txt'];
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
