function hash = string2hash(str)
    % Substituir strings inválidas por um valor padrão
    if isempty(str) || str == "" || str == "NA"
        str = "default";  % Garantir que temos uma string válida
    end

    % Gera um valor hash para uma string usando o algoritmo DJB2
    str = double(str); % Converter string para valores numéricos
    
    % Se a conversão resultar em NaN, tratar como string padrão
    if any(isnan(str))
        str = double("default");  % Garantir valores válidos
    end
    
    hash = 5381; 
    for i = 1:length(str)
        % Garantir que a operação não resulta em overflow
        hash = mod(hash * 33 + str(i), 2^32); % Manter hash dentro de 32 bits
    end
end
