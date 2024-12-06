function minhashes = computeMinHashes(text, numHashes)
    % Divide o texto em palavras, remove stopwords e converte para minúsculas
    stopwords = ["a", "e", "de", "que", "do", "da", "dos", "das", "em", "um", "uma", "para", "por", "com", "sobre"];
    words = split(lower(text));
    words = setdiff(words, stopwords);
    words = unique(words);
    
    % Inicializa os valores mínimos para cada função de hash
    minhashes = inf(1, numHashes);
    
    % Calcula hashes para cada palavra
    for i = 1:length(words)
        wordHash = simpleHash(words{i}, numHashes);
        minhashes = min(minhashes, wordHash);
    end
end

function hashValues = simpleHash(word, numHashes)
    % Função que gera valores de hash para uma palavra com múltiplas funções
    hashValues = zeros(1, numHashes);
    
    % Para cada hash, cria uma semente com base na palavra
    for i = 1:numHashes
        rng(i + sum(double(word)));
        hashValues(i) = mod(randi([0, 1e6]), 1e6);
    end
end

function similarity = calculateJaccardSimilarity(title1, title2, numHashes)

    minhashes1 = computeMinHashes(title1, numHashes);
    minhashes2 = computeMinHashes(title2, numHashes);
    
    similarity = sum(minhashes1 == minhashes2) / numHashes; 
end
