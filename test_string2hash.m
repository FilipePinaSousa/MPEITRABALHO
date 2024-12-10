% Teste com strings simples
strings = ["apple", "orange", "banana", "grape"];

% Hash com DJB2
hashDJB2 = string2hash(strings, 'djb2');
disp('Hashes com DJB2:');
disp(hashDJB2);

% Hash com SDBM
hashSDBM = string2hash(strings, 'sdbm');
disp('Hashes com SDBM:');
disp(hashSDBM);
