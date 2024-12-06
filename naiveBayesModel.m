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
    validTitles = titles ~= "";
    titles = titles(validTitles);
    domains = domains(validTitles);
    labels = labels(validTitles);
    
    % Processar os domínios como uma variável categórica
    uniqueDomains = unique(domains);
    domainFeatures = zeros(length(titles), length(uniqueDomains));
    
    for i = 1:length(titles)
        domainIdx = strcmp(uniqueDomains, domains(i));
        domainFeatures(i, domainIdx) = 1;
    end
    
    % Processar as palavras dos títulos
    documents = tokenizedDocument(titles);  
    bag = bagOfWords(documents);            
    
    % Obter contagens das palavras
    countsTitles = full(bag.Counts);       

    % Limitar o número de palavras para as mais frequentes (por exemplo,top 50)
    [~, sortedIdx] = sort(sum(countsTitles, 1), 'descend'); 
    topWordsIdx = sortedIdx(1:50);
    countsTitles = countsTitles(:, topWordsIdx);
    
    % Concatenar as contagens de palavras e as características de domínio
    domainFeaturesSparse = sparse(domainFeatures);
    features = [countsTitles, domainFeaturesSparse];
    
    % Verificar a variância das características
    featureVariance = var(features, 0, 1);
    disp('Variância de cada coluna de características:');
    disp(featureVariance);
    
    % Remover colunas com variância zero
    nonZeroVarianceColumns = featureVariance > 0;
    features = features(:, nonZeroVarianceColumns);
    
    % Obter as classes únicas e calcular a probabilidade a priori de cada classe
    classLabels = categories(labels);
    numClasses = numel(classLabels);    
    numInstances = length(labels);     
    priors = zeros(numClasses, 1);      
    
    % Calcular a probabilidade a priori para cada classe
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
