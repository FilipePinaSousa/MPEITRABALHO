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
    userShingles = generateShingles(userTitle, shinglesSize);

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
    
    % Normalize strings
    userTitle = normalizeString(userTitle);
    titles = arrayfun(@normalizeString, titles);
    
    for i = 1:length(titles)
        % Check for exact match
        if strcmp(userTitle, titles(i))
            similarity(i) = 1.0;
            continue;
        end
        
        % Word-based similarity
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
    % Remove quotes and normalize spaces
    str = lower(strip(str));
    str = strrep(str, '''', '');
    str = regexprep(str, '\s+', ' ');
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