function classifyDomains(databaseFile, naiveBayesModel)
    % Ler os dados do arquivo e carregar o modelo Naive Bayes
    data = readtable(databaseFile, 'TextType', 'string');
    load(naiveBayesModel, 'model'); 
    
    % Inicializar tabela para armazenar resultados
    domainTrustList = table('Size', [0 2], 'VariableTypes', {'string', 'logical'}, 'VariableNames', {'Domain', 'IsTrusted'});
    
    % Processar cada domínio nos dados
    for i = 1:height(data)
        % Verificar se o domínio é válido
        if ~ismissing(data.source_domain{i}) & ~strcmp(data.source_domain{i}, 'NA') & strlength(data.source_domain{i}) > 0
            domain = string(data.source_domain{i});
        else
            domain = 'Invalid URL';
        end
        
        if strcmp(domain, 'Invalid URL')
            fprintf('Invalid domain for entry %d\n', i);
            continue;
        end
        
        % Construir vetor de características usando string2hash
        domainHash = string2hash(domain);  % Gerar hash do domínio
        titleHash = string2hash(data.title{i}); % Gerar hash do título
        featureVector = [mod(domainHash, 100), mod(titleHash, 100)]; % Normalizar os hashes
        
        % Fazer a previsão com o modelo Naive Bayes
        prediction = predictNaiveBayes(model, featureVector);
        
        % Exibir o tipo e valor da previsão para depuração
        fprintf('Prediction type: %s, value: %s\n', class(prediction), mat2str(prediction));
        
        % Determinar se o domínio é confiável
        isTrusted = prediction == 1; 
        domainTrustList = [domainTrustList; {domain, isTrusted}];
    end
    
    % Exibir a lista final de domínios confiáveis
    disp('Domain Trust List:');
    disp(domainTrustList);
end

% Função de predição Naive Bayes
function prediction = predictNaiveBayes(model, featureVector)
    numClasses = numel(model.classLabels);
    classLogProbs = log(model.priors); % Log dos priors das classes
    
    % Computar a verossimilhança logarítmica para cada classe
    for classIdx = 1:numClasses
        for featureIdx = 1:length(featureVector)
            % Verificar se a característica existe no modelo
            if featureVector(featureIdx) > 0 && featureVector(featureIdx) <= size(model.condProbs, 2)
                classLogProbs(classIdx) = classLogProbs(classIdx) + ...
                                          log(model.condProbs(classIdx, featureVector(featureIdx)));
            else
                % Penalizar características fora do modelo
                classLogProbs(classIdx) = classLogProbs(classIdx) - 1; 
            end
        end
    end
    
    % Prever a classe com maior probabilidade logarítmica
    [~, predictedClassIdx] = max(classLogProbs);  
    prediction = model.classLabels(predictedClassIdx);
    
    % Garantir que a previsão seja retornada no formato correto
    if iscell(prediction)
        prediction = prediction{1};
    end
end
