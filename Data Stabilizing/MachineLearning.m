var = load('classify_var.mat');
var = var.classify_var;

X = var(:, 1:end-1);
Y = var(:, end);

cv = cvpartition(size(var, 1), 'holdout', 0.40);

% Training set
Xtrain = X(training(cv), :);
Ytrain = Y(training(cv), :);
% Test set
Xtest = X(test(cv), :);
Ytest = Y(test(cv), :);

% Train classifier
da = fitensemble(Xtrain,Ytrain,'bag',200,'tree','type','Classification');

[Y_da, Yscore_da] = predict(da, Xtest);

C_da = confusionmat(Ytest, Y_da);



% actual run

    filename = 'Trial 5.csv';
    offset = [5, 2];
    var = csvread(filename, offset(1), offset(2));
    
[col_length, row_length] = size(var);
dimens = 3;
parts = row_length / dimens;

output_var = nan(size(var));
for part = 0:parts-1
    xyz = [part*3 + 1, part*3 + 2, part*3 + 3];
    
    [Y_da, Yscore_da] = predict(da, var(:, xyz(1):xyz(3)));
    
    for row = 1:col_length
        output_var(row, Y_da(row)*3 + 1:Y_da(row)*3 + 3) = var(row, xyz(1):xyz(3));
    end
end

hold off
for part = 0:parts-1
    xyz = [part*3 + 1, part*3 + 2, part*3 + 3];

    % ignore nan variables
    idxs = ~isnan(output_var(:, xyz(1)));
    idys = ~isnan(output_var(:, xyz(2)));
    idzs = ~isnan(output_var(:, xyz(3)));

    plot3(output_var(idxs, xyz(1)), output_var(idys, xyz(2)), output_var(idzs, xyz(3)));
    hold on
end
grid on