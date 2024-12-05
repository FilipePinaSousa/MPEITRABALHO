function naiveBayesModel(databaseFile)
    % Carregar os dados
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Extrair títulos e rótulos
    titles = strtrim(string(data.title))'; 
    domains = data.source_domain';        
    labels = categorical(data.real)';  
    
    % Remover entradas inválidas (NA ou vazio) nos domínios
    validRows = ~ismissing(domains) & domains ~= "NA";
    titles = titles(validRows);
    domains = domains(validRows);
    labels = labels(validRows);
    
    % Remover títulos vazios ou inválidos
    validTitles = titles ~= "";  % Excluir títulos vazios
    titles = titles(validTitles); % Atualizar títulos válidos
    domains = domains(validTitles); % Atualizar domínios
    labels = labels(validTitles);   % Atualizar rótulos
    
    % Processar os domínios como uma variável categórica
    uniqueDomains = unique(domains);  % Obter domínios únicos
    domainFeatures = zeros(length(titles), length(uniqueDomains));  % Inicializar a matriz de características
    
    for i = 1:length(titles)
        domainIdx = strcmp(uniqueDomains, domains(i));  % Encontrar o índice do domínio
        domainFeatures(i, domainIdx) = 1;  % Definir a coluna correspondente ao domínio como 1
    end
    
    % Processar as palavras dos títulos
    documents = tokenizedDocument(titles);  % Tokenizar títulos
    bag = bagOfWords(documents);            % Criar uma bolsa de palavras
    
    % Obter contagens das palavras
    countsTitles = full(bag.Counts);       

    % Limitar o número de palavras para as mais frequentes (por exemplo, 50)
    [~, sortedIdx] = sort(sum(countsTitles, 1), 'descend');  % Ordenar as palavras por frequência
    topWordsIdx = sortedIdx(1:50);  % Selecionar as 50 palavras mais frequentes
    countsTitles = countsTitles(:, topWordsIdx);  % Reduzir as contagens às palavras mais frequentes
    
    % Concatenar as contagens de palavras e as características de domínio
    domainFeaturesSparse = sparse(domainFeatures);
    features = [countsTitles, domainFeaturesSparse];
    
    % Verificar a variância das características
    featureVariance = var(features, 0, 1); % Variância por coluna
    disp('Variância de cada coluna de características:');
    disp(featureVariance);
    
    % Remover colunas com variância zero
    nonZeroVarianceColumns = featureVariance > 0;
    features = features(:, nonZeroVarianceColumns);
    
    % Obter as classes únicas e calcular a probabilidade a priori de cada classe
    classLabels = categories(labels);  % Obter as classes únicas
    numClasses = numel(classLabels);    % Número de classes
    numInstances = length(labels);      % Número total de instâncias
    priors = zeros(numClasses, 1);      % Probabilidades a priori de cada classe
    
    % Calcular a probabilidade a priori para cada classe
    for i = 1:numClasses
        priors(i) = sum(labels == classLabels(i)) / numInstances;
    end
    
    % Calcular a probabilidade condicional de cada característica dado a classe
    condProbs = zeros(numClasses, size(features, 2));  % Inicializar a matriz de probabilidades condicionais
    for i = 1:numClasses
        classInstances = features(labels == classLabels(i), :);  % Filtrar instâncias da classe
        condProbs(i, :) = (sum(classInstances, 1) + 1) / (size(classInstances, 1) + 2);  % Laplace smoothing
    end
    
    % Salvar o modelo treinado
    model.priors = priors;
    model.condProbs = condProbs;
    model.classLabels = classLabels;
    save('naiveBayesModel.mat', 'model');
    disp('Modelo treinado e salvo.');
end
