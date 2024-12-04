function classifyDomains(databaseFile, naiveBayesModel)
    % Load dataset
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Load Naive Bayes model
    load(naiveBayesModel, 'mdl');
    
    % Initialize list to store domain trust information
    domainTrustList = table('Size', [0 2], 'VariableTypes', {'string', 'logical'}, 'VariableNames', {'Domain', 'IsTrusted'});
    
    % Initialize counters for statistics
    totalDomains = 0;
    trustedCount = 0;
    untrustedCount = 0;
    
    % Process each article
    for i = 1:height(data)
        % Extract domain from URL
        domain = extractDomain(data.url(i));
        
        % Skip invalid URLs
        if strcmp(domain, 'Invalid URL')
            continue;
        end
        
        % Get true label for the article (assuming 'label' is 1 for true, 0 for fake)
        trueLabel = data.label(i);
        
        % Create a bag-of-words representation from the title
        bow = bagOfWords(data.title(i));
        
        % Use Naive Bayes model to predict the label
        prediction = predict(mdl, bow);
        
        % Determine trustworthiness based on prediction
        isTrusted = prediction == 1;  % If predicted as 'true' (1), it is trusted
        
        % Add domain and trust status to the list
        domainTrustList = [domainTrustList; {domain, isTrusted}];
        
        % Update counters
        totalDomains = totalDomains + 1;
        if isTrusted
            trustedCount = trustedCount + 1;
        else
            untrustedCount = untrustedCount + 1;
        end
        
        % Optionally display prediction vs actual
        if trueLabel == 1
            trueLabelStr = 'trusted';
        else
            trueLabelStr = 'untrusted';
        end
        
        if isTrusted
            predictionStr = 'trusted';
        else
            predictionStr = 'untrusted';
        end
        
        fprintf('Domain: %s, True Label: %s, Predicted: %s\n', domain, trueLabelStr, predictionStr);
    end
    
    % Show the trust list
    disp('Domain Trust List:');
    disp(domainTrustList);
    
    % Display Summary Statistics
    fprintf('Total Domains Processed: %d\n', totalDomains);
    fprintf('Trusted Domains: %d\n', trustedCount);
    fprintf('Untrusted Domains: %d\n', untrustedCount);
    fprintf('Percentage Trusted: %.2f%%\n', (trustedCount / totalDomains) * 100);
    fprintf('Percentage Untrusted: %.2f%%\n', (untrustedCount / totalDomains) * 100);
end
