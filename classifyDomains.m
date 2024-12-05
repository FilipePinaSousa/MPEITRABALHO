function classifyDomains(databaseFile, naiveBayesModel)
    % Load dataset
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Load Naive Bayes model
    load(naiveBayesModel, 'model'); 
    
    % Initialize list to store domain trust information
    domainTrustList = table('Size', [0 2], 'VariableTypes', {'string', 'logical'}, 'VariableNames', {'Domain', 'IsTrusted'});
    
    % Create a bag-of-words object for the entire dataset
    documents = tokenizedDocument(data.title);
    bag = bagOfWords(documents);
    [~, sortedIdx] = sort(sum(bag.Counts, 1), 'descend');
    topWordsIdx = sortedIdx(1:50);  % Example: top 50 features
    bagCounts = bag.Counts(:, topWordsIdx);

    % Process each article
    for i = 1:height(data)
        % Extract domain
        if ~ismissing(data.source_domain{i}) & ~strcmp(data.source_domain{i}, 'NA')
            domain = string(data.source_domain{i});
        else
            domain = 'Invalid URL';
        end
        
        if strcmp(domain, 'Invalid URL')
            continue;  % Skip entries with invalid URLs
        end
        
        % Feature vector
        featureVector = bagCounts(i, :);

        % Prediction
        prediction = predictNaiveBayes(model, featureVector);
        fprintf('Prediction type: %s, value: %s\n', class(prediction), mat2str(prediction)); % Debugging
        
        % Trustworthiness
        isTrusted = prediction == 1;  % Modify if prediction is string
        domainTrustList = [domainTrustList; {domain, isTrusted}];
    end
    
    % Show results
    disp('Domain Trust List:');
    disp(domainTrustList);
end

% Naive Bayes prediction function using priors and conditional probabilities
function prediction = predictNaiveBayes(model, featureVector)
    % Initialize prediction variable
    numClasses = numel(model.classLabels);
    classLogProbs = log(model.priors);  % Start with log priors
    
    % Compute the log likelihood for each class
    for classIdx = 1:numClasses
        % Add log probabilities of each feature given the class
        for featureIdx = 1:length(featureVector)
            if featureVector(featureIdx) == 1  % Only consider features that are present
                classLogProbs(classIdx) = classLogProbs(classIdx) + log(model.condProbs(classIdx, featureIdx));
            end
        end
    end
    
    % Predict the class with the highest log probability
    [~, predictedClassIdx] = max(classLogProbs);  % Get the index of the max log probability
    prediction = model.classLabels(predictedClassIdx);  % Assign the corresponding class label
    
    % Handle cases where classLabels might be a cell array
    if iscell(prediction)
        prediction = prediction{1};  % Convert cell to string or scalar
    end
end

% Helper function to extract domain from URL
function domain = extractDomain(url)
    try
        % Use MATLAB's built-in parsing for URLs
        parsedUrl = matlab.net.URI(url);
        domain = parsedUrl.Host;  % Extract the host (domain) from the URL
        if isempty(domain)
            domain = 'Invalid URL';
        end
    catch
        domain = 'Invalid URL';  % Handle parsing errors
    end
end
