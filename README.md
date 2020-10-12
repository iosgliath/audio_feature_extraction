# audio_feature_extraction


This file impletements audio feature extraction techniques while using the less external packages possible.<br/>
Mainly, it aims to obtain Mel Frequency Cepstral Coefficents as well as Deltas and Delta-Deltas of those coefficients.<br/>

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
   FFTW.jl for Discrete Cosine transform ( mydct() is a work in progress)<br/>
   Plots.jl for ... plotting <br/>

<strong>How to use :</strong><br/>

    λsr, ϕl, powspec, bin, fbankDB, fmfcc, ∇fmfcc, ∇∇fmfcc = generateFeatures(file, preemph = 0.97, ϕl = 0.025, ∇ϕ = 0.01, nfilt=20, num_ceps = 12)
    myplot!(file, powspec, fbankDB, fmfcc, bin, λsr, ϕl, start=1, finish=0, colors="warm")

    
  #   generateFeatures() will return signal features
  
   file = .wav <br/>
   λsr = sample rate<br/>
   premph = pre emphasis filtering coefficient (first filtering of signal) <br/>
   ϕl = window length (adjusted to power of 2 for Cooley Tuckey FFT input constrain)<br/>
   ∇ϕ = hopsize in secs <br/>
   nfilt = number of filters for generating mel scale <br/>
   num_ceps = amount of cepsta to keep<br/>
   filterbanks = Mel space banks of size (nfilt, nframes)<br/>
   fmfcc = Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)<br/>
   ∇fmfcc = Delta Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)<br/>
   ∇∇fmfcc = Delta Delta Mel Frequency Cepstral Coefficient of size ( num_ceps, nframes)<br/>
   N = upper range limit for Delta MFCC computation. Usually = 2 <br/>
   start/finish = starting/ending range for frame plotting. If finish = 0, plot all frames<br/>
   
 #   myplot!() will return a mosaic of plots
   filename followed by frequency of maximal power spectral density for the first frame of the batch<br/>
   4 bins of the power spectrum (frames 1, 10, 20 and 30)<br/>
   a heatmap of the filter banks<br/>
   a heatmap of the MFCCs<br/>
   
   ![image info](./output.png)

Yeah! We have an approx of the fundamental frequency of this piano key while only looking at the max powspec of the first frame of the signal!

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

