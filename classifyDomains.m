function classifyDomains(databaseFile, naiveBayesModel)

    data = readtable(databaseFile, 'TextType', 'string');
    load(naiveBayesModel, 'model'); 
    
    % Inicializar e armazenar informação confiavel
    domainTrustList = table('Size', [0 2], 'VariableTypes', {'string', 'logical'}, 'VariableNames', {'Domain', 'IsTrusted'});
    
    % Criar a bag-of-words object para o dataset
    documents = tokenizedDocument(data.title);
    bag = bagOfWords(documents);
    [~, sortedIdx] = sort(sum(bag.Counts, 1), 'descend');
    topWordsIdx = sortedIdx(1:50);
    bagCounts = bag.Counts(:, topWordsIdx);

    % Procesar cada um dos dominios
    for i = 1:height(data)
        % Extrair os dominios
        if ~ismissing(data.source_domain{i}) & ~strcmp(data.source_domain{i}, 'NA')
            domain = string(data.source_domain{i});
        else
            domain = 'Invalid URL';
        end
        
        if strcmp(domain, 'Invalid URL')
            continue;
        end
        
        featureVector = bagCounts(i, :);
        prediction = predictNaiveBayes(model, featureVector);
        fprintf('Prediction type: %s, value: %s\n', class(prediction), mat2str(prediction)); 
        isTrusted = prediction == 1; 
        domainTrustList = [domainTrustList; {domain, isTrusted}];
    end
    
    disp('Domain Trust List:');
    disp(domainTrustList);
end

% Naive Bayes prediction function que usa priors e probabilidades condicionais
function prediction = predictNaiveBayes(model, featureVector)
    numClasses = numel(model.classLabels);
    classLogProbs = log(model.priors); 
    
    % Computar o the log likelihood para cada classe
    for classIdx = 1:numClasses
        
        for featureIdx = 1:length(featureVector)
            if featureVector(featureIdx) == 1
                classLogProbs(classIdx) = classLogProbs(classIdx) + log(model.condProbs(classIdx, featureIdx));
            end
        end
    end
    
    % Predict the class with the highest log probability
    [~, predictedClassIdx] = max(classLogProbs);  
    prediction = model.classLabels(predictedClassIdx); 
    
    %casos que são cell arrays
    if iscell(prediction)
        prediction = prediction{1};
    end
end

% Função de extração de dominios
function domain = extractDomain(url)
    try
        % Uso MATLAB's built-in para o parsing de URL
        parsedUrl = matlab.net.URI(url);
        domain = parsedUrl.Host;
        if isempty(domain)
            domain = 'Invalid URL';
        end
    catch
        domain = 'Invalid URL';
    end
end
