function hash = string2hash(str)
    % Gera um valor hash para uma string usando o algoritmo DJB2
    str = double(str); % Converter string para valores numéricos
    hash = 5381; 
    for i = 1:length(str)
        hash = mod(hash * 33 + str(i), 2^32); % Manter hash dentro de 32 bits
    end
end
