function findSimilarTitlesMinHash(databaseFile, inputTitle)
    % Load and preprocess data
    data = readtable(databaseFile, 'TextType', 'string');
    titles = data.title;
    
    % MinHash parameters
    numHashes = 100;
    shinglesSize = 2;
    similarityThreshold = 0.1;
    
    % Generate signatures matrix
    signatures = zeros(height(data), numHashes);
    
    % Process each title
    for i = 1:height(data)
        title = preprocessTitle(titles(i));
        shingles = generateShingles(title, shinglesSize);
        signatures(i,:) = computeMinHashSignature(shingles, numHashes);
    end
    
    % Preprocess input title (no user input)
    userTitle = preprocessTitle(inputTitle);
    userShingles = generateShingles(userTitle, shinglesSize);
    userSignature = computeMinHashSignature(userShingles, numHashes);
    
    % Find similar titles
    similarities = computeWordBasedSimilarity(userTitle, titles);
    [sortedSim, indices] = sort(similarities, 'descend');
    
    % Display results
    fprintf('\nChecking similarities for: "%s"\n', inputTitle);
    displaySimilarTitles(data, sortedSim, indices, similarityThreshold);
end

function similarity = computeWordBasedSimilarity(userTitle, titles)
    % Initialize similarity vector
    similarity = zeros(length(titles), 1);
    
    % Convert user title to word set
    userWords = lower(split(userTitle));
    userWords = unique(userWords);
    
    % Compare with each title
    for i = 1:length(titles)
        % Convert current title to word set
        titleWords = lower(split(titles(i)));
        titleWords = unique(titleWords);
        
        % Calculate Jaccard similarity using unique for set operations
        allWords = [userWords; titleWords];
        uniqueWords = unique(allWords);
        intersection = length(userWords) + length(titleWords) - length(uniqueWords);
        unionSize = length(uniqueWords);
        
        if unionSize > 0
            similarity(i) = intersection / unionSize;
        else
            similarity(i) = 0;
        end
    end
end

function title = preprocessTitle(title)
    title = lower(title);
    title = regexprep(title, '[^\w\s]', '');
end

function shingles = generateShingles(text, k)
    shingles = {};
    words = strsplit(text);
    if length(words) >= k
        for i = 1:(length(words)-k+1)
            shingle = strjoin(words(i:i+k-1));
            shingles{end+1} = shingle;
        end
    else
        shingles{1} = strjoin(words);
    end
end

function signature = computeMinHashSignature(shingles, numHashes)
    signature = inf(1, numHashes);
    for i = 1:numHashes
        for j = 1:length(shingles)
            hashValue = string2hash(shingles{j}, 'djb2', i);
            signature(i) = min(signature(i), hashValue);
        end
    end
end

function displaySimilarTitles(data, similarities, indices, threshold)
    fprintf('\nSimilar titles found:\n');
    for i = 1:min(5,length(indices))
        if similarities(i) >= threshold
            fprintf('%.2f%% similar: %s\n', ...
                similarities(i)*100, ...
                data.title(indices(i)));
        end
    end
end