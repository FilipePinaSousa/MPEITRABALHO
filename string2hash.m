% Função string2hash utilizando djb2
function hash = string2hash(str, type, seed)
    % Verificar se a entrada é uma string válida
    if ~isstring(str) || isempty(str) || str == "NA" || strtrim(str) == ""
        str = "default";
    end

    % Converter para char se necessário
    str = convertStringsToChars(str);

    % Usar semente no hash para variabilidade
    if nargin < 3
        seed = 1; % Semente padrão
    end

    hash = uint32(seed);  % Inicializa com a semente

    % Validar tipo de hash
    validTypes = ["djb2", "sdbm", "md5", "sha1"];
    if nargin < 2
        type = 'djb2';
    end

    if ~ismember(type, validTypes)
        error('Tipo de hash desconhecido. Use "djb2", "sdbm", "md5" ou "sha1".');
    end

    % Usar algoritmo djb2
    switch type
        case 'djb2'
            % Algoritmo DJB2
            for i = 1:numel(str)
                hash = mod(hash * 33 + uint32(str(i)), 2^32 - 1); % Atualiza hash
            end
        case 'sdbm'
            % Algoritmo SDBM
            for i = 1:numel(str)
                hash = mod(hash * 65599 + uint32(str(i)), 2^32 - 1); % Atualiza hash
            end
    end
end