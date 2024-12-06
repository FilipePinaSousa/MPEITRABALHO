function classifyDomains(databaseFile, naiveBayesModel)
    % Read the data and load the Naive Bayes model
    data = readtable(databaseFile, 'TextType', 'string');
    load(naiveBayesModel, 'model'); 
    
    % Initialize list to store domain trust information
    domainTrustList = table('Size', [0 2], 'VariableTypes', {'string', 'logical'}, 'VariableNames', {'Domain', 'IsTrusted'});
    
    % Initialize a map to count the number of fake news per domain
    fakeNewsCount = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    
    % Process each article
    for i = 1:height(data)
        % Extract domain using the custom extractDomain function
        domain = string(data.source_domain{i});
        
        % Debugging output to check the extracted domain
        fprintf('Entry %d - Extracted domain: "%s"\n', i, domain);
        
        % Skip invalid domains
        if strcmp(domain, 'Invalid URL')
            fprintf('Skipping invalid domain for entry %d: "%s"\n', i, domain);
            continue;
        end
        
        % Extract title (if available)
        if ismember('title', data.Properties.VariableNames)
            title = data.title{i};
        else
            title = "default";  % Default value if title is missing
        end
        
        % Validate title
        if any(ismissing(title)) || strlength(title) == 0
            title = "default";  % Use default if title is missing or empty
        end
        
        % Feature vector (using domain and title hashes)
        domainHash = string2hash(domain);
        titleHash = string2hash(title);
        featureVector = [mod(domainHash, 100), mod(titleHash, 100)];
        
        % Make prediction using Naive Bayes model
        prediction = predictNaiveBayes(model, featureVector);
        
        % Determine if the domain is trusted (based on prediction)
        isTrusted = prediction == 1; 
        
        % If the domain is untrusted, increment the fake news count
        if ~isTrusted
            if isKey(fakeNewsCount, domain)
                fakeNewsCount(domain) = fakeNewsCount(domain) + 1;
            else
                fakeNewsCount(domain) = 1;
            end
        end
        
        % Append to the domainTrustList only if it's not already in the list
        if ~any(domainTrustList.Domain == domain)
            domainTrustList = [domainTrustList; {domain, isTrusted}];
        end
    end
    
    % Update domain trust list based on the fake news count
    for i = 1:height(domainTrustList)
        domain = domainTrustList.Domain{i};
        
        % If the domain has more than 5 fake news instances, mark it as untrusted
        if isKey(fakeNewsCount, domain) && fakeNewsCount(domain) > 5
            domainTrustList.IsTrusted(i) = false;
            fprintf('Domain "%s" has more than 5 fake news instances. Marking as untrusted.\n', domain);
        end
    end
    
    % Display the final domain trust list
    disp('Domain Trust List:');
    disp(domainTrustList);
end

% Naive Bayes prediction function
function prediction = predictNaiveBayes(model, featureVector)
    numClasses = numel(model.classLabels);
    classLogProbs = log(model.priors);  % Log of priors
    
    % Compute log likelihood for each class
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
    
    % Ensure prediction is in the correct format
    if iscell(prediction)
        prediction = prediction{1};
    end
end
