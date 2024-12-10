function classifyDomains(databaseFile, naiveBayesModel)
    % Ler os dados do arquivo e carregar o modelo Naive Bayes
    data = readtable(databaseFile, 'TextType', 'string');
    load(naiveBayesModel, 'model'); 
    
    % Inicializar lista para armazenar informações de confiança dos domínios
    domainTrustList = table('Size', [0 2], 'VariableTypes', {'string', 'logical'}, 'VariableNames', {'Domain', 'IsTrusted'});
    
    % Inicializar um mapa para contar o número de notícias falsas por domínio
    fakeNewsCount = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    
    % Processar cada artigo
    for i = 1:height(data)
        % Extrair o domínio usando a função personalizada extractDomain
        domain = string(data.source_domain{i});
        
        % Exibição para depuração para verificar o domínio extraído
        fprintf('Entrada %d - Domínio extraído: "%s"\n', i, domain);
        
        % Pular domínios inválidos
        if strcmp(domain, 'Invalid URL')
            fprintf('Pulando domínio inválido na entrada %d: "%s"\n', i, domain);
            continue;
        end
        
        % Extrair o título (se disponível)
        if ismember('title', data.Properties.VariableNames)
            title = data.title{i};
        else
            title = "default"; 
        end
        
        % Validar título
        if any(ismissing(title)) || strlength(title) == 0
            title = "default";
        end
        
        % Vetor de características (usando hashes do domínio e do título)
        domainHash = string2hash(domain);
        titleHash = string2hash(title);
        featureVector = [mod(domainHash, 100), mod(titleHash, 100)];
        
        % Fazer a previsão usando o modelo Naive Bayes
        prediction = predictNaiveBayes(model, featureVector);
        
        % Determinar se o domínio é confiável (baseado na previsão)
        isTrusted = prediction == 1; 
        
        % Se o domínio não for confiável, incrementar o contador de notícias falsas
        if ~isTrusted
            if isKey(fakeNewsCount, domain)
                fakeNewsCount(domain) = fakeNewsCount(domain) + 1;
            else
                fakeNewsCount(domain) = 1;
            end
        end
        
        % Adicionar à lista de confiança de domínios somente se ainda não estiver na lista
        if ~any(domainTrustList.Domain == domain)
            domainTrustList = [domainTrustList; {domain, isTrusted}];
        end
    end
    
    % Atualizar a lista de confiança dos domínios com base na contagem de notícias falsas
    for i = 1:height(domainTrustList)
        domain = domainTrustList.Domain{i};
        
        % Se o domínio tiver mais de 5 instâncias de notícias falsas, marcá-lo como não confiável
        if isKey(fakeNewsCount, domain) && fakeNewsCount(domain) > 5
            domainTrustList.IsTrusted(i) = false;
            fprintf('Domínio "%s" tem mais de 5 instâncias de notícias falsas. Marcando como não confiável.\n', domain);
        end
    end
    
    % Exibir a lista final de confiança de domínios
    disp('Lista de Confiança dos Domínios:');
    disp(domainTrustList);
end

% Função de previsão do Naive Bayes
function prediction = predictNaiveBayes(model, featureVector)
    % Número de classes no modelo
    numClasses = numel(model.classLabels);
    % Calcular os logaritmos das probabilidades a priori
    classLogProbs = log(model.priors);
    
    % Calcular a verossimilhança logarítmica para cada classe
    for classIdx = 1:numClasses
        for featureIdx = 1:length(featureVector)
            if featureVector(featureIdx) == 1
                classLogProbs(classIdx) = classLogProbs(classIdx) + log(model.condProbs(classIdx, featureIdx));
            end
        end
    end
    
    % Prever a classe com a maior probabilidade logarítmica
    [~, predictedClassIdx] = max(classLogProbs);  
    prediction = model.classLabels(predictedClassIdx); 
    
    % Garantir que a previsão esteja no formato correto
    if iscell(prediction)
        prediction = prediction{1};
    end
end
