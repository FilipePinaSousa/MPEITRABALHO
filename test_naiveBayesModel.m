function test_naiveBayesModel()
    % Use the actual FakeNewsNet dataset
    databaseFile = 'FakeNewsNet.csv';
    
    % Train the Naive Bayes model with the actual dataset
    disp('Treinando o modelo com o conjunto de dados FakeNewsNet...');
    naiveBayesModel(databaseFile);
    
    % Load the trained model
    load('naiveBayesModel.mat', 'model');
    
    % Check the model type
    disp('Modelo treinado:');
    disp(model);
    
    % Test the model by making a prediction for a new title
    testTitle = "Sample article title for testing";  % Example title for prediction
    bow = bagOfWords(testTitle);
    % Assuming the source domain for this article is 'bbc.com'
    sourceDomain = 'bbc.com';
    uniqueDomains = unique({'bbc.com', 'cnn.com', 'nytimes.com'}); % Update with actual domains in your dataset
    domainFeature = zeros(1, length(uniqueDomains));
    domainIdx = strcmp(uniqueDomains, sourceDomain);
    domainFeature(domainIdx) = 1;  % Set the domain feature
    
    % Combine the title bag-of-words with the domain feature
    features = [bow.Counts, domainFeature];
    
    % Make prediction
    prediction = predict(model, features);
    
    % Display the prediction
    disp(['Predição para o título "', testTitle, '": ', string(prediction)]);
end
