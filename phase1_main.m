%% PHASE 1 - Component & Material Database
clear; clc; close all;

T = createMaterialDB();
C = createComponentDB();

for i = 1:height(C)
    for j = 1:numel(C.Materials{i})
        if ~any(strcmp(T.Name, C.Materials{i}{j}))
            error('Material "%s" (component %s) is not in the database.', ...
                C.Materials{i}{j}, C.Component{i});
        end
    end
end
disp('Legitable databse.');

T.SpecStrength  = T.Yield ./ (T.Density/1000);   % MPa/(g/cm^3)
T.SpecStiffness = T.E ./ (T.Density/1000);       % GPa/(g/cm^3)

comp = 'Battery Enclosure';
mats = getCandidateMaterials(C, comp);
fprintf('\nCandiate material for %s:\n', comp);
for i = 1:numel(mats)
    m = getMaterial(T, mats{i});
    fprintf('  %-18s rho=%5d kg/m3 | Sy=%4d MPa | E=%5.1f GPa | %5.1f USD/kg\n', ...
        m.Name, m.Density, m.Yield, m.E, m.Cost);
end

figure('Name','Material comparison');
subplot(1,2,1);
bar(categorical(T.Name), T.SpecStrength);
ylabel('Specific strength [MPa/(g/cm^3)]'); grid on; xtickangle(30);
subplot(1,2,2);
bar(categorical(T.Name), T.Cost);
ylabel('Cost [USD/kg]'); grid on; xtickangle(30);

save('materialLibrary.mat','T','C');
disp('Saved materialLibrary.mat');