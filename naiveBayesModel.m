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
    % Gerar hashes para domínios e títulos
    domainHash = string2hash(domains(i));
    titleHash = string2hash(titles(i));
    
    % Normalizar os hashes para evitar problemas de overflow
    domainFeatures(i) = domainHash;
    titleFeatures(i) = titleHash;
    
    % Depuração: Exibir os valores dos hashes
    if mod(i, 10) == 0  % Exibir a cada 10 instâncias
        fprintf('Instância %d: Domain Hash = %d, Title Hash = %d\n', i, domainFeatures(i), titleFeatures(i));
    end
end
    
    
    % Concatenar as características
    features = [domainFeatures, titleFeatures];
    
    % Verificar a variância das características
    featureVariance = var(features, 0, 1);
    disp('Variância de cada coluna de características:');
    disp(featureVariance);
    
    % Verificar se há características válidas antes de remover
    if all(isnan(featureVariance))
        error('Todas as variâncias são NaN. Verifique os dados de entrada e a geração das características.');
    end
    
    % Remover colunas com variância zero
    nonZeroVarianceColumns = featureVariance > 0;
    
    % Checar se há colunas válidas restantes
    if ~any(nonZeroVarianceColumns)
        error('Nenhuma característica válida após a remoção de colunas com variância zero.');
    end
    
    features = features(:, nonZeroVarianceColumns);
    
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
        condProbs(i, :) = (sum(classInstances, 1) + 1) / (size(classInstances, 1) + 2); 
    end
    
    % Salvar o modelo treinado
    model.priors = priors;
    model.condProbs = condProbs;
    model.classLabels = classLabels;
    save('naiveBayesModel.mat', 'model');
    disp('Modelo treinado e salvo.');
end
