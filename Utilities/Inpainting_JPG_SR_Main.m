function  [reconstructed_image, PSNR_Final, FSIM_Final, SSIM_Final, All_PSNR, Outloop,Err_or] = Inpainting_JPG_SR_Main(y,Options, ratio)




mask            =              Options.A;

A               =              @(x) mask.*x;

AT              =              @(x) mask.*x;

ATy             =              AT(y);

%mu = Options.mu;
mu1             =              Options.mu1; % Parameter for PSR

mu2             =              Options.mu2; % Parameter for GSR

Thr             =              Options.Thr;

x               =              Options.initial;

IterNums        =              Options.IterNums;

true            =              Options.true;

b               =              zeros(size(y));

c               =              zeros(size(y));

%w               =              zeros(size(y));

muinv           =              1/(mu1+mu2);

invAAT          =             1./((mu1+mu2)+mask);


fprintf('Initial PSNR = %0.2f\n',csnr(x,true,0,0));

All_PSNR       =              zeros(1,IterNums);

 JPG_SR_Results          =                      cell (1,IterNums);   
 
 
 if  ratio<= 0.1
     
     difff  =  0.00099;
     
 elseif ratio<= 0.2
     
     difff  =  0.0011;
     
 elseif ratio<= 0.3
     
    difff  =  0.00092;
     
 elseif ratio<= 0.4
     
    difff  =  0.0011;
     
 elseif ratio<= 0.5
     
    difff  =  0.0014;
     
 else
     
    difff  =  0.0005;
     
 end
     
     

for Outloop = 1:IterNums
          
        z                =                  Solver_PSR(x-b,Thr);
        
        w                =                  Solve_GSR(x-c,Options);
        
        r                =                  ATy + mu1*(z+b)+mu2*(w+c);
        
        x                =                  muinv*(r - AT(invAAT.*A(r)));
           
        b                =                  b + (z - x);
    
        c                =                  c + (w - x);
        
   All_PSNR(Outloop)     =               csnr(x,true,0,0);
   
      JPG_SR_Results{Outloop}      =                      x;
    
    fprintf('iter number = %d, PSNR = %0.2f\n',Outloop,csnr(x,true,0,0));

    
    if Outloop>4
        
      Err_or      =  norm(abs(JPG_SR_Results{Outloop}) - abs(JPG_SR_Results{Outloop-1}),'fro')/norm(abs(JPG_SR_Results{Outloop-1}), 'fro');

        
        if Err_or < difff
            
            break;
            
        end
        
    end
    
    
end

reconstructed_image             =                 x;

PSNR_Final                      =                 csnr(reconstructed_image,true,0,0);

FSIM_Final                      =                 FeatureSIM(reconstructed_image,true);

SSIM_Final                      =                 cal_ssim(reconstructed_image,true,0,0);

end

