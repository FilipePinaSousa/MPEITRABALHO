function findSimilarTitlesMinHash(databaseFile)
    % Load and preprocess data
    data = readtable(databaseFile, 'TextType', 'string');
    titles = data.title;

    % MinHash parameters
    numHashes = 100;
    shinglesSize = 2;
    similarityThreshold = 0.1;

    % Generate signatures matrix
    signatures = zeros(height(data), numHashes);

    % Initialize waitbar
    h = waitbar(0, 'Processing titles...');

    % Process each title
    for i = 1:height(data)
        title = preprocessTitle(titles(i));
        shingles = generateShingles(title, shinglesSize);
        signatures(i,:) = computeMinHashSignature(shingles, numHashes);
        
        % Update waitbar
        waitbar(i/height(data), h);
    end

    % Close waitbar
    close(h);

    % Get user input
    userTitle = input('Enter title to check: ', 's');
    userTitle = preprocessTitle(userTitle);

    % Initialize similarity calculation waitbar
    h = waitbar(0, 'Calculating similarities...');

    % Find similar titles
    similarities = computeWordBasedSimilarity(userTitle, titles, h);
    [sortedSim, indices] = sort(similarities, 'descend');

    % Close waitbar
    close(h);

    % Display results
    displaySimilarTitles(data, sortedSim, indices, similarityThreshold);
end

function similarity = computeWordBasedSimilarity(userTitle, titles, h)
    similarity = zeros(length(titles), 1);
    
    % Normalize input title and titles list
    userTitle = normalizeString(userTitle);
    titles = arrayfun(@normalizeString, titles);
    
    for i = 1:length(titles)
        % Check for exact match first
        if strcmp(userTitle, titles(i))
            similarity(i) = 1.0; % 100% similarity for exact match
            continue;
        end
        
        % Word-based similarity (Jaccard similarity)
        userWords = unique(split(userTitle));
        titleWords = unique(split(titles(i)));
        
        intersection = sum(ismember(userWords, titleWords));
        union = length(unique([userWords; titleWords]));
        
        if union > 0
            similarity(i) = intersection / union;
        end

        % Update waitbar every 100 iterations
        if mod(i, 100) == 0
            waitbar(i/length(titles), h);
        end
    end
end

function str = normalizeString(str)
    % Convert to lowercase
    str = lower(str);
    
    % Remove all special characters except spaces
    str = regexprep(str, '[^a-z0-9\s]', '');
    
    % Normalize spaces (replace multiple spaces with one)
    str = regexprep(str, '\s+', ' ');
    
    % Trim leading/trailing spaces
    str = strtrim(str);
end

function title = preprocessTitle(title)
    % Convert to lowercase
    title = lower(title);
    
    % Remove all non-alphanumeric characters except spaces
    title = regexprep(title, '[^a-z0-9\s]', '');
    
    % Normalize spaces
    title = regexprep(title, '\s+', ' ');
    
    % Trim leading/trailing spaces
    title = strtrim(title);
end

function shingles = generateShingles(text, k)
    % Generate k-word shingles from the text
    shingles = {};
    words = strsplit(text);
    if length(words) >= k
        for i = 1:(length(words)-k+1)
            shingle = strjoin(words(i:i+k-1));
            shingles{end+1} = shingle; %#ok<AGROW>
        end
    else
        shingles{1} = strjoin(words);
    end
end

function signature = computeMinHashSignature(shingles, numHashes)
    % Compute the MinHash signature for the given shingles
    signature = inf(1, numHashes);
    for i = 1:numHashes
        for j = 1:length(shingles)
            hashValue = string2hash(shingles{j}, 'djb2', i);
            signature(i) = min(signature(i), hashValue);
        end
    end
end

function displaySimilarTitles(data, similarities, indices, threshold)
    % Display similar titles based on threshold
    fprintf('\nSimilar titles found:\n');
    for i = 1:min(5, length(indices))
        if similarities(i) >= threshold
            fprintf('%.2f%% similar: %s\n', ...
                similarities(i)*100, ...
                data.title(indices(i)));
        end
    end
end

function hash = string2hash(str, method, seed)
    % Hash function for strings
    if nargin < 3
        seed = 0;
    end
    if strcmp(method, 'djb2')
        hash = seed;
        for i = 1:length(str)
            hash = mod(hash * 33 + double(str(i)), 2^32);
        end
    else
        error('Unknown hashing method');
    end
end
