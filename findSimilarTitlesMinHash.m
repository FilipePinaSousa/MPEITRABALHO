function findSimilarTitlesMinHash(databaseFile)
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Parâmetros para MinHash
    numHashes = 100; 
    shinglesSize = 1; 
    
    % Criar MinHash assinaturas
    signatures = zeros(height(data), numHashes);
    for i = 1:height(data)
        shingles = generateShingles(data.title(i), shinglesSize);
        signatures(i, :) = generateMinHashWithString2Hash(shingles, numHashes);
    end
    
    % Comparar assinaturas
    for i = 1:height(data)
        for j = i+1:height(data)
            similarity = calculateMinHashSimilarity(signatures(i, :), signatures(j, :));
            fprintf('Similaridade entre os títulos:\n');
            fprintf('Título 1: %s\nTítulo 2: %s\nSimilaridade MinHash: %.2f\n\n', ...
                data.title(i), data.title(j), similarity);
        end
    end
end

function shingles = generateShingles(text, k)
    % Normalizar texto
    text = lower(regexprep(text, '[^\w\s]', ''));
    tokens = split(text); 

    % Remover stop words
    stopWords = ["the", "and", "to", "of", "in", "on", "a", "for"]; 
    tokens = tokens(~ismember(tokens, stopWords));

    % Gerar shingles de tamanho k
    shingles = [];
    if numel(tokens) >= k
        for i = 1:(numel(tokens) - k + 1)
            shingle = strjoin(tokens(i:i+k-1), ' ');
            shingles = [shingles; shingle];
        end
    else
        shingles = tokens; % Se menos tokens que k, usar como está
    end
end


function signature = generateMinHashWithString2Hash(shingles, numHashes)
    % Parâmetros para hashing
    numShingles = numel(shingles);
    signature = inf(1, numHashes); % Inicializa com infinito

    % Gerar funções de hash baseadas no índice
    for i = 1:numHashes
        for j = 1:numShingles
            % Calcula o hash usando string2hash
            hashValue = mod(string2hash(shingles{j}) + i, 2^31 - 1);
            if hashValue < signature(i)
                signature(i) = hashValue; % Atualiza o menor valor
            end
        end
    end
end

function similarity = calculateMinHashSimilarity(sig1, sig2)
    similarity = sum(sig1 == sig2) / numel(sig1);
end
