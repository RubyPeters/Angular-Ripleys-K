
AngularRipleysKForDemoData 

origoutput = dlmread('OutputDataOrig.txt');

assert(all((origoutput(:) - Hvaluesdata(:)) < 0.05))