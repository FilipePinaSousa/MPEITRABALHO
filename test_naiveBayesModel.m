function test_naiveBayesModel()
    % Use the actual FakeNewsNet dataset
    databaseFile = 'FakeNewsNet.csv';
    
    % Train the Naive Bayes model with the actual dataset
    disp('Treinando o modelo com o conjunto de dados FakeNewsNet...');
    naiveBayesModel(databaseFile);  % Treina e salva o modelo em 'naiveBayesModel.mat'
    
    % Load the trained model
    load('naiveBayesModel.mat', 'model');
    
    % Check the model type
    disp('Modelo treinado:');
    disp(model);
    
    % Test the model by making a prediction for a new title
    testTitle = "Sample article title for testing";
    
    % Tokenize and create a bag-of-words for the test title
    documents = tokenizedDocument(testTitle);
    bow = bagOfWords(documents);
    
    % Match the test bag-of-words to the top words used in training
    topWords = model.topWordsIdx; % Assume 'model.topWords' contains the vocabulary used
    testFeatureVector = zeros(1, length(topWords));
    for i = 1:length(topWords)
        word = topWords{i};
        idx = find(strcmp(bow.Vocabulary, word)); % Match the word to test title
        if ~isempty(idx)
            testFeatureVector(i) = bow.Counts(idx); % Set the count for the word
        end
    end
    
    % Simulate the domain feature for the test case
    sourceDomain = 'bbc.com';  % Example domain for the test article
    uniqueDomains = model.domains; % Assume 'model.domains' contains domains used in training
    domainFeature = zeros(1, length(uniqueDomains));
    domainIdx = strcmp(uniqueDomains, sourceDomain);
    if any(domainIdx)
        domainFeature(domainIdx) = 1;
    end
    
    % Combine the title bag-of-words with the domain feature
    featureVector = [testFeatureVector, domainFeature];
    
    % Make prediction using the trained model
    prediction = predictNaiveBayes(model, featureVector);
    
    % Display the prediction
    disp(['Predição para o título "', testTitle, '" com o domínio "', sourceDomain, '": ', string(prediction)]);
end
