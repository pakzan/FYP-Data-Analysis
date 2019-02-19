function grad = getSmoothGrad(time, var)
    grad = zeros(size(var,1), size(var,2));
    for i = 1:size(var,2)
        grad(:,i) = 1000 * diff([var(1,i); var(:,i)])./diff([eps; time]);
        %smooth data
        grad(:,i) = smooth(time, grad(:,i),0.3,'rloess');
    end
end