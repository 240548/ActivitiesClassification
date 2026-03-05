% -------------------------------------------------------------------------
% BPC-ABS                           2023                Maláňová Katarína
% Semestrální projekt                                      Podhorná Petra 
% -------------------------------------------------------------------------
%  Funkce pro klasifikaci fyzických aktivit z akcelerometrických signálů
% -------------------------------------------------------------------------

% Volání funkce, signál uložen v proměnné D
function classADL = rozpoznaniAktivit(D)

% převzorkování se vzorkovací frekvencí 200 Hz
fvz = 200;
tosa = linspace(0, length(D)/fvz-1/fvz, length(D));

% určení časového rozsahu trvání signálu
t_range = tosa(end)-tosa(1);

% jednotlivé osy
x = D(:, 1);
y = D(:, 2);
z = D(:, 3);

% spojení signálu ze všech tří os do jednoho pomocí Euklidovské normy
euklid = sqrt(x.^2+y.^2+z.^2);

% vytvoření amplitudového spektra signálu
spektr = abs(fft(euklid));

% výpočet maximální a průměrné hodnoty spektra
maxx = max(spektr);
meann = mean(spektr);

% zarovnání signálu na nulovou izolínii
euklid = euklid-1;

% určení výšky píků nad hodnotu 0.35 a jejich lokace
[peaks, locks] = findpeaks(euklid, "MinPeakHeight", 0.35);
l = length(locks);         % počet píků
if l == 0                  % skrytí varovných hlášení, pokud počet píků bude nulový
    warning("off", "all"); 
end

% rozdělení aktivit na 2 hlavní skupiny 
% 1. SKUPINA
if l > 20                                                     % pokud je počet píků větší než 20
    [peaks2, locks2] = findpeaks(euklid, "MinPeakHeight", 1); % určení výšky píků č.2 nad hodnotu 1 a jejich lokace
    l2 = length(locks2)/t_range;                              % počet píků č.2 na 1 s časového rozsahu signálu
     
    if maxx <= 3000       % pokud je max. frekvence ve spektru větší než 3000 Hz
        if l2 < 2         % pokud je počet píků č.2 větší než 2
            classADL = 1; % aktivita = chůze
        else              % pokud je počet píků č.2 menší nebo rovný 2
            classADL = 2; % aktivita = běh
        end
    else                              % pokud je max. frekvence ve spektru nižší než 3000 Hz
        duration = diff(locks2./fvz); % podíl jednotlivých vzdáleností mezi píky č.2 a vzorkovací frkevencí,
                                      % tzn. výpočet doby trvání kroků
        mean_diff = mean(duration);   % průměrná doba trvání kroku

        if mean_diff > 1.25 % pokud je průměrná doba trvání jednoho kroku vyšší než 1.25 s
            classADL = 5;  % aktivita = chůze nahoru po schodech
        else               % pokud je průměrná doba trvání jednoho kroku nižší neobo rovna 1.25 s
            classADL = 4;  % aktivita = chůze dolů po schodech
        end
    end

% 2. SKUPINA
else                                                            % pokud je počet píků menší než 20
    [peaks3, locks3] = findpeaks(euklid, "MinPeakHeight", 0.5); % určení výšky píků č.3 nad hodnotu 0.5 a jejich lokace
    l3 = length(locks3);                                        % počet píků č.3
    
    if meann >= 6 && l3 > 3  % pokud je průměrná frekvence ve spektru alespoň 6 Hz a počet píků č.3 větší než 3
        end_of_y = y(end);   % koncová hodnota zrychlení na ose y po vykonání aktivity
        if end_of_y > 0.8    % pokud je hodnota zrychlení vyšší než 0.8 m.s^-2
            classADL = 3;    % aktivita = skok
        else                   % pokud je hodnota zrychlení nižší nebo rovna 0.8 m.s^-2
            max_of_x = max(x); % maximální hodnota zrychlení na ose x
            if max_of_x < 1.5  % pokud je hodnota zrychlení nižší než 1.5 m.s^-2
                classADL = 8;  % aktivita = pád dozadu
            else                   % pokud je hodnota zrychlení vyšší nebo rovna 1.5 m.s^-2
                max_of_z = max(z); % maximální hodnota zrychlení na ose z
                if max_of_z > 2.5  % pokud je hodnota zrychlení vyšší než 2.5 m.s^-2
                    classADL = 7;  % aktivita = pád do boku
                else               % pokud je hodnota zrychlení nižší než 2.5 m.s^-2
                    classADL = 6;  % aktivita = pád dopředu
                end
            end
        end
    
    else                   % pokud je průměrná frekvence ve spektru nižší než 6 Hz a počet píků č.3 nižší nebo rovný 3
        end_of_x = x(end); % koncová hodnota zrychlení na ose x po vykonání aktivity
        if end_of_x < -0.7 % pokud pokud je hodnota zrychlení nižší než -0.7 m.s^-2
            classADL = 9;  % aktivita = lehnutí
        else               % pokud pokud je hodnota zrychlení vyšší nebo rovna -0.7 m.s^-2
            classADL = 10; % aktivita = ostatní
        end
    end

end