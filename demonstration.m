% Fake News Detection System Demonstration
fprintf('=== Fake News Detection System Demo ===\n\n');

% 1. Load and prepare data
dataFile = 'FakeNewsNet.csv';
fprintf('1. Loading data from %s...\n', dataFile);
data = readtable(dataFile, 'TextType', 'string');
fprintf('Loaded %d news articles.\n\n', height(data));

% 2. Train Naive Bayes Model
fprintf('2. Training Naive Bayes Model...\n');
naiveBayesModel(dataFile);
fprintf('Testing Naive Bayes Model...\n');
test_naiveBayesModel('naiveBayesModel.mat');
fprintf('\n');

% 3. Initialize Bloom Filter for Popular Articles
fprintf('3. Processing Popular Articles with Bloom Filter...\n');
FamoustitlesWithBloomFilter(dataFile);
fprintf('\n');

% 4. Find Similar Articles using MinHash
fprintf('4. MinHash Similarity Detection...\n');

% Example titles for similarity check
sampleTitles = {
    'Breaking news about covid vaccine',
    'New study reveals vaccine effectiveness',
    'Weather forecast for tomorrow'
};

% Loop through predefined titles
for i = 1:length(sampleTitles)
    findSimilarTitlesMinHash('FakeNewsNet.csv', sampleTitles{i});
end

% 5. Domain Classification
fprintf('\n5. Classifying News Domains...\n');
classifyDomains(dataFile, 'naiveBayesModel.mat');

% 6. Final Summary
fprintf('\n=== System Performance Summary ===\n');
fprintf('- Naive Bayes Classification completed\n');
fprintf('- Popular articles identified with Bloom Filter\n');
fprintf('- Similar articles detected with MinHash\n');
fprintf('- Domain trust levels evaluated\n');
fprintf('\nDemo completed successfully!\n');
