function naiveBayesModel(databaseFile)
    % Carregar os dados
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Extrair títulos, domínios e rótulos
    titles = strtrim(string(data.title))';
    domains = data.source_domain';
    labels = categorical(data.real)';  
    
    % Remover entradas inválidas (NA ou vazio) nos domínios
    validRows = ~ismissing(domains) & domains ~= "NA";
    titles = titles(validRows);
    domains = domains(validRows);
    labels = labels(validRows);
    
    % Remover títulos vazios ou inválidos
    validTitles = titles ~= "";
    titles = titles(validTitles);
    domains = domains(validTitles);
    labels = labels(validTitles);
    
    % Construir características usando string2hash
    numInstances = length(titles);
    domainFeatures = zeros(numInstances, 1);
    titleFeatures = zeros(numInstances, 1);

    for i = 1:numInstances
        % Validar os dados antes de gerar o hash
        if strlength(domains(i)) > 0 && strlength(titles(i)) > 0
            % Gerar hashes para domínios e títulos
            domainHash = string2hash(domains(i));
            titleHash = string2hash(titles(i));
            
            % Atribuir os valores dos hashes às características
            domainFeatures(i) = domainHash; % Use o valor completo sem mod
            titleFeatures(i) = titleHash;  % Use o valor completo sem mod
        else
            % Marcar entradas inválidas como NaN
            domainFeatures(i) = NaN;
            titleFeatures(i) = NaN;
            fprintf('Entrada inválida na instância %d: Domain = "%s", Title = "%s"\n', i, domains(i), titles(i));
        end
        
        % Depuração: Exibir os valores dos hashes
        if mod(i, 10) == 0
            fprintf('Instância %d: Domain Hash = %d, Title Hash = %d\n', i, domainFeatures(i), titleFeatures(i));
        end
    end
    
    % Remover instâncias inválidas
    validInstances = ~isnan(domainFeatures) & ~isnan(titleFeatures);
    domainFeatures = domainFeatures(validInstances);
    titleFeatures = titleFeatures(validInstances);
    labels = labels(validInstances);
    
    % Normalizar as características
    domainRange = max(domainFeatures) - min(domainFeatures);
    if domainRange > 0
        domainFeatures = (domainFeatures - min(domainFeatures)) / domainRange;
    end
    
    titleRange = max(titleFeatures) - min(titleFeatures);
    if titleRange > 0
        titleFeatures = (titleFeatures - min(titleFeatures)) / titleRange;
    end

    % Calcular a variância e verificar
    featureVariance = [var(domainFeatures), var(titleFeatures)];
    disp('Variância de cada característica:');
    disp(featureVariance);

    if any(isnan(featureVariance))
        error('Algumas variâncias são NaN. Verifique os dados de entrada e a geração das características.');
    end
    
    % Concatenar as características para o modelo
    features = [domainFeatures, titleFeatures];

    % Obter as classes únicas e calcular a probabilidade a priori de cada classe
    classLabels = categories(labels);
    numClasses = numel(classLabels);
    priors = zeros(numClasses, 1);
    
    for i = 1:numClasses
        priors(i) = sum(labels == classLabels(i)) / numInstances;
    end
    
    % Calcular a probabilidade condicional de cada característica dado a classe
    condProbs = zeros(numClasses, size(features, 2));
    for i = 1:numClasses
        classInstances = features(labels == classLabels(i), :);
        condProbs(i, :) = mean(classInstances, 1); % Calcula diretamente a média condicional
    end

    % Salvar o modelo treinado
    model.priors = priors;
    model.condProbs = condProbs;
    model.classLabels = classLabels;
    model.features = features;
    save('naiveBayesModel.mat', 'model');
    disp('Modelo treinado e salvo.');
end
