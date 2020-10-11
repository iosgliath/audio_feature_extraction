# audio_feature_extraction


This file impletements audio feature extraction techniques while using the less external packages possible.<br/>
Mainly, it aims to obtain Mel Frequency Cepstral Coefficents as well as Deltas and Delta-Deltas of those coefficients.<br/>

"In sound processing, the mel-frequency cepstrum (MFC) is a representation of the short-term power spectrum of a sound, based on a linear cosine transform of a log power spectrum on a nonlinear mel scale of frequency."<br/>
https://en.wikipedia.org/wiki/Mel-frequency_cepstrum

http://practicalcryptography.com/miscellaneous/machine-learning/guide-mel-frequency-cepstral-coefficients-mfccs/<br/>

Helped me hack this out.<br/>
Great read.<br/>
Go read it.<br/>


Using<br/>
    WAV.jl for reading .wav file <br/>
    FFTW.jl for Discrete Cosine transform ( mydct() is working in progress)<br/>

How to use :

    λsr, ϕl, powspec, bin, fbankDB, fmfcc, ∇fmfcc, ∇∇fmfcc = generateFeatures(file, preemph = 0.97, ϕl = 0.025, ∇ϕ = 0.01, nfilt=20, num_ceps = 12)
    myplot!(file, powspec, fbankDB, fmfcc, bin, λsr, ϕl, start=1, finish=0, colors="warm")

    λsr = sample rate
    ϕl = window length ( converted to power of 2 for Cooley Tuckey FFT implementation)

   fmfcc = Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)
   ∇fmfcc = Delta Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)
   ∇∇fmfcc = Delta Delta Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)
    
  #   generateFeatures() will return our features
   takes several paremeters as input:
       file -> .wav // 
       premph -> pre emphasis filtering coefficient (first filtering of signal) // 
       ϕl -> window length in secs // 
       ∇ϕ -> hopsize in secs // 
       nfilt -> number of filters for generating mel scale // 
       num_ceps -> number of MFCCs to keep for each frame // 



 #   myplot!() will return a mosaic of plots
   filename followed by frequency of maximal power spectral demnsity for the first frame of the batch
   4 bins of the power spectrum (frames 1, 10, 20 and 30)
   a heatmap of the filter banks
   a heatmap of the MFCCs



  #  General process :
   input signal 
        -> premph filt 
        -> framing 
        -> window transform 
        -> discrete fourrier transform 
        -> log 
        -> discrete cosine transform

   For now, only Hamming window is implemented.

