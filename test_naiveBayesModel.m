function test_naiveBayesModel(modelFile)
    % Load data and model
    testData = readtable('FakeNewsNet.csv', 'TextType', 'string');
    load(modelFile, 'model');

    % Print initial statistics
    fprintf('Number of instances: %d\n', height(testData));
    fprintf('Number of model classes: %d\n\n', length(model.classLabels));

    % Preprocess test data
    titles = lower(strtrim(string(testData.title)));
    domains = lower(testData.source_domain);
    labels = categorical(testData.real);

    % Generate features matching the training model
    numInstances = length(titles);
    numFeatures = 10;  % Matched with training features
    features = zeros(numInstances, numFeatures);
    
    for i = 1:numInstances
        % Basic features
        features(i,1) = string2hash(domains(i));
        features(i,2) = strlength(titles(i));
        features(i,3) = count(titles(i), ' ') + 1;
        features(i,4) = sum(isstrprop(char(titles(i)), 'punct')) / strlength(titles(i));
        features(i,5) = sum(isstrprop(char(titles(i)), 'upper')) / strlength(titles(i));
        
        words = split(titles(i));
        features(i,6) = mean(strlength(words));
        features(i,7) = sum(~isstrprop(char(titles(i)), 'alphanum')) / strlength(titles(i));
        
        % Additional features
        features(i,8) = count(titles(i), "!");
        features(i,9) = count(titles(i), "?");
        features(i,10) = sum(isstrprop(char(titles(i)), 'digit')) / strlength(titles(i));
    end

    % Normalize features using robust statistics
    for j = 1:size(features,2)
        if range(features(:,j)) > 0
            median_val = median(features(:,j));
            mad_val = mad(features(:,j), 1);
            features(:,j) = (features(:,j) - median_val) / (mad_val + eps);
        end
    end

    % Make predictions
    scores = zeros(numInstances, length(model.classLabels));
    for i = 1:numInstances
        for j = 1:length(model.classLabels)
            scores(i,j) = log(model.priors(j)) + sum(log(max(features(i, :), 1e-10)) .* model.condProbs(j,:));
        end
    end
    
    [~, predictionIndices] = max(scores, [], 2);
    predictions = model.classLabels(predictionIndices);

    % Calculate accuracy
    accuracy = mean(predictions == labels);
    fprintf('Model accuracy: %.2f%%\n', accuracy * 100);
end