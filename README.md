# audio_feature_extraction


This file impletements audio feature extraction techniques while using the less external packages possible.<br/>
Mainly, it aims to obtain Mel Frequency Cepstral Coefficents as well as Deltas and Delta-Deltas of those coefficients.<br/>

Those coefficients will later be used as input vectors for a note classification model.<br/>
Later comits will try to implement and play around this [paper](https://pdf.sciencedirectassets.com/280203/1-s2.0-S1877050912X00061/1-s2.0-S1877050912006424/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEgaCXVzLWVhc3QtMSJIMEYCIQDql2G2kAaRIM8kxvh%2Fi5fiJjN3UxP42VbQ%2BEuVR7cNvAIhAJwdAHpZljxW6kjQfDHN6RhcmLYTwud7%2FrGNwdHf0NthKr0DCIH%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQAxoMMDU5MDAzNTQ2ODY1IgxIunqAK%2FRv0mQMOxkqkQO%2BngOVGO%2Bsauv9bods7D5IUZDTge1nbh7oCAOOyzy8G5GhMejl3sZIIbIJzWI0PbE5z%2F4wMZOvs2nsdBDNAep%2BP2kmJRXOhMhzG2Mh0Zk2r3EcuZN9sGGU3wX5wBmW2r2yuKs3SauGVB4Ln%2BGw0UH5iII6qOQa0pl6twDkGB3Vf2n2nthKGtOcSosHCtYVqfAUann4bbfPAUZgXF8YPpKx9eexYMx4BK8anhwbvRSekf%2BJG68HyCgzgUVgQcY3zoht3MhvSGdzpz24u6%2BlnOWka9pjQp0PNrNuJLkxVYftfIb7K%2F4J31MeMSYn0NPmY8h%2B5%2FeuMgQP3yw0F9L1DhByDqnbOf4iMAtCEMD85a8RcByDTCaZK2%2FeMV2kUJISvAheWE94wDynABVj4aEYYBpDAZOPwRC3zPTGsST0HzizQZE0u0Je6QP6TqTmmkMpfGmUvjhUq0s9ULcz546de9ld4uYwpDWduRO2PcFeuNHuQplAPzEwGZgWsXq3Ldsp7K5AQurAXk3tQkVip%2FkMe1CMhTCJrY78BTrqAc3LoX%2FGeM4EwLbGX7Nkxx5lmry0c4t6LOF5z6Tva5DFccktZpBs2U2k1Ir3hvjtn2ui%2FTx0ewLScywQ5W3pH2MHRDEF4m9f9EZMSQzStcZatBD6ek1He%2FcZd4JGY6NHj7b%2FXziStZD%2Fybz3r1ecbiIwY3oJCoKzhl2fiqn621y26J%2BXlOES%2FOXlVQeDBD9FBMFlwHaF81hKK2s6AcseOiVFLCiTN%2BKozN4mw3JAZ5Z1VP1a98FNBJ1gOZvixcadPk3HLvdDcbQynUfccDDfkw8NUm637w4hT%2FBtNMB09SQ%2BcbahPS5K9qsrqQ%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20201012T011655Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYTLMKFKEJ%2F20201012%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=f452cf3a9316739b6985eaa327fd188b19fc69776c8017ab866514a814dc4cc7&hash=39d0e007f9f306fcf605a855c6f5e4c752ee89f8ff8cf64302156e15103ee9d9&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S1877050912006424&tid=spdf-6a2dcf9e-0180-4df4-a8ed-bae0cf653cea&sid=ad9454e75c41f347ee79906311234e6ed8f1gxrqb&type=client "paper"), following the same philosophy.<br/>

"In sound processing, the mel-frequency cepstrum (MFC) is a representation of the short-term power spectrum of a sound, based on a linear cosine transform of a log power spectrum on a nonlinear mel scale of frequency."<br/>
https://en.wikipedia.org/wiki/Mel-frequency_cepstrum


Planning to later expend on this with better documentation and explain the MFCCs extraction process from start to finish.<br/>
Beware, nothing new under the sun, this is project is learning oriented.<br/>
If you have any feedback, keep it coming. <br/>

http://practicalcryptography.com/miscellaneous/machine-learning/guide-mel-frequency-cepstral-coefficients-mfccs/<br/>
Helped me hack this out.<br/>
Great read.<br/>
Go read it.<br/>

<strong>Using</strong><br/>

   WAV.jl for reading .wav file <br/>
   FFTW.jl for Discrete Cosine transform only ( mydct() is a work in progress)<br/>
   Plots.jl for ... plotting <br/>

<strong>How to use :</strong><br/>

    λsr, ϕl, powspec, bin, fbankDB, fmfcc, ∇fmfcc, ∇∇fmfcc = generateFeatures(file, preemph = 0.97, ϕl = 0.025, ∇ϕ = 0.01, nfilt=20, num_ceps = 12)
    myplot!(file, powspec, fbankDB, fmfcc, bin, λsr, ϕl, start=1, finish=0, colors="warm")

    
  #   generateFeatures() will return signal features
 
   <strong>file</strong> = .wav <br/>
   <strong>λsr</strong> = sample rate<br/>
   <strong>premph</strong> = pre emphasis filtering coefficient (first filtering of signal) <br/>
   <strong>ϕl</strong> = window length in secs (later auto adjusted to power of 2 samples for Cooley Tukey FFT input constrain)<br/>
   <strong>∇ϕ</strong> = hopsize in secs <br/>
   <strong>nfilt</strong> = number of filters for generating mel scale <br/>
   <strong>num_ceps</strong> = amount of cepstra to keep<br/>
   <strong>filterbanks</strong> = Mel space banks of size (nfilt, nframes)<br/>
   <strong>fmfcc</strong> = Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)<br/>
   <strong>∇fmfcc</strong> = Delta Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)<br/>
   <strong>∇∇fmfcc</strong> = Delta Delta Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)<br/>
   <strong>N</strong> = upper range limit for Delta MFCC computation. Usually = 2 <br/>
   <strong>start / finish</strong> = starting/ending range for frame plotting. If finish = 0, plot all frames<br/>
   
 #   myplot!() will return a mosaic of plots
   filename followed by frequency of maximal power spectral density for the first frame of the batch<br/>
   4 bins of powspec (frames 1, 10, 20 and 30)<br/>
   a heatmap of the filter banks<br/>
   a heatmap of the MFCCs<br/>
   
   <strong>Input signal = time domain</strong><br/>
    ![image info](./input.png)
    <strong>Output = frequency domain analysis</strong><br/>
    ![image info](./output.png)
    
We can see harmonic resonances in the filter banks.<br/>
Yeah! From the base audio signal, we have isolated the fundamental frequency of this piano key, while only looking at the max powspec of the first frame of the signal!

  #  General process :
   input signal <br/>
        -> premph filt <br/>
        -> framing <br/>
        -> window transform <br/>
        -> discrete fourrier transform (Cooley Tuckey radix 2 DIT FFT) <br/>
        -> convert to Mel space <br/>
        -> log <br/>
        -> discrete cosine transform<br/>

   For now, only Hamming window is implemented.

