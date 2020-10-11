using Plots, WAV, FFTW

"""
Pro tip
  if you see λ, it says something about the audio signal time space
  if you see ϕ, it says something about the frames the signal is partioned in
  if you see n, it says something about an amount
  if you see l, it says something about a length

  => ϕn would be intuitively the quantity of frames we manipulate
  => λl would be intuitively the length of time domain signal
"""

computeϕl(λsr, ϕl) = nextpow(2, λsr * ϕl)

function hamming(n::T, N::T) where {T <: Integer}
  0.5*(1-cos(2π*n/(N-1)))
end

function ϕing(λ::Array{T}, ϕl::Integer, ϕ∇::Integer) where {T<:Real}
    """
    takes as input
        signal λ
        frame length ϕl
        frame step ϕ∇
    output framed signal, where window function was applied to each frames
    output of size size (ϕl, ϕn)
    """
    λl = length(λ)
    (ϕn, rem) = fldmod(λl,ϕ∇)
    if rem > 0
      λ = vcat(λ, zeros(Float64, ϕl-rem))
      ϕn += 1
    end

  #pad signal end with 0 -> pad length depends on ϕl ans ϕ∇
    padλ(λ) = vcat(λ, zeros(Float64, ϕl))
    λ = padλ(λ)

    # create array with framed signal of size (ϕl, ϕn)
    ϕs = hcat( [ λ[i:i+ϕl-1] for i in 1:ϕ∇:λl ]... )

    return ϕs
end

function window(ϕs)
    """
    takes frames as input
    output frames where window function on each frames
  
    for now, only hamming -> 0.5*(1-cos(2π*n/(N-1)))
    """
    ϕl = size(ϕs, 1)
    w = hamming.(collect(1:ϕl), ϕl+1)
    wϕs = mapslices(x -> x.*w, ϕs, dims = 1)
    return wϕs
end

function ctfft(θ)
    """
    Cooley Tukey 2 DIT FFT implementation
    """

    m = length(θ)

    !ispow2(m) && print("signal length must be power of 2, cutting sequence (prevpow2::Julia)")

    if m > 2
        λ1 = ctfft(θ[1:2:m])
        λ2 = ctfft(θ[2:2:m])
    elseif m == 2
        λ1 = θ[1]
        λ2 = θ[2]
    else
        return print("signal length must > 1")
    end

    n = 0:m-1
    half = div(m,2)
    ϵ = exp.(-2im*π*n/m)

    return vcat( λ1 .+ λ2 .* ϵ[1:half], λ1 .- λ2 .* ϵ[1:half] )
end

function computeFilterBanks(nfilt=26, ϕl=512, λsr=16000)
    #to do dig into lowfreq = zero issue !
    lowfreq = 100
    # highfreq is sample rate / 2
    highfreq = λsr / 2

    # convert lowfreq and highfreq to mel space => edges of mel bands
    lowmel = hz2mel(lowfreq)
    highmel = hz2mel(highfreq)

    # compute points evenly spaced in mel space
    ∇ = (highmel - lowmel) / (nfilt+1)
    mel_points = lowmel:∇:highmel
    # translate band ranges drom mel space back to hertz space
    hz_points = mel2hz.(mel_points)

    bin = floor.((ϕl + 1) * hz_points / λsr)
    fbank = zeros(nfilt, fld(ϕl, 2)+1)

    for m in 2:nfilt+1
        fl = trunc(Int, bin[m - 1])
        fc = trunc(Int, bin[m])
        fr = trunc(Int, bin[m + 1])

        for k in fl:fc
            fbank[m - 1, k] = (k - bin[m - 1]) / (bin[m] - bin[m - 1])
        end
        for k in fc:fr
            fbank[m - 1, k] = (bin[m + 1] - k) / (bin[m + 1] - bin[m])
        end
    end
    return fbank, bin
end

function hz2mel(hz)
    2595*log10(1+(hz/700))
end

function mel2hz(mel)
    700*(exp(mel/1127.01048)-1)
end

function fftλ(λ::Vector, λsr::Float64, ϕl::Float64, ϕ∇::Float64)

    # convert winwow length from time space to fft bins while nforcing pow2 for cooley tukey fft input constrain
    ϕl = computeϕl(λsr, ϕl)
  
    # framing signal : from vector input to array of size (framelength=ϕl, framecount=ϕn)
    ϕs = ϕing( λ, ϕl, trunc( Int, ϕ∇*λsr ) )
    wϕs = window(ϕs)

    # compute fft
    dft = mapslices(x->ctfft(x), wϕs, dims=1)

    #keep only (nfft/2)+1 length
    dft = dft[1:fld(ϕl, 2)+1,:]

    magnitude = mapslices(x->abs.(x), dft, dims=1)
    powspec = mapslices(x->abs2.(x)/ϕl, dft, dims=1)
  
    return powspec
end

function mydct(v::Vector)
  
  # not getting same results as with FFTW package, so not using it for now
  
    n = length(v)
    y = zeros(Float64, n)
    for i = 1:n
        sum = 0
        if i == 1
            s = sqrt(0.5)
        else
            s = 1
        end
        for j = 1:n
            sum += s * v[j] * cos(π * (j + .5) * i / n);
        end
        y[i] = sum * sqrt(2 / n);
    end
  
    return y
end

function compute∇mffc(mfcc, N)
  
    # input of mfcc of size ( nfilt, nframes)
    nfilt = size(mfcc, 1)
    ϕn = size(mfcc, 2)

    # output ∇mfcc of size ( nfilt, nframes)
    ∇mfcc = zeros(Float64, nfilt, ϕn)

    # padd mfcc frames with N * zeros(nfilts, 1) on each side
    # mfcc becomes size ( nfilt, nframes + 2 * N)
    for i = 1:N
        mfcc = hcat(zeros(Float64, nfilt), mfcc, zeros(Float64, nfilt))
    end

    # pϕn is padded mfcc frame count
    pϕn = size(mfcc, 2)

    # for each frame, at each filter, calculate ∇mfcc = ∑{n=1:N}[ n * (c[t+n] - c[t-n]) ] / ∑{n=1:N}[ 2 * n^2 ]
    for i = 1:nfilt, j in 1:ϕn
        for n = 1:N
            # mfcc are padded, while using output coordinates => add pad length to mfcc coor
            ∇mfcc[i,j] += n * ( mfcc[i,j+N+n] - mfcc[i,j+N-n] ) / ( 2 * sqrt(n) )
        end
    end
  
    return ∇mfcc
end

function generateFeatures(file; preemph=0.97, ϕl = 0.025, ∇ϕ = 0.01, nfilt= 20, num_ceps = 12, N = 2)

    data, fs, nbits = wavread(file, format="native")

    # from stereo to mono
    data = reshape(data[:,1], length(data[:,1]), 1)

    # data janitoring, to Float64
    λsr = convert(Float64, fs)
    λ = convert(Array{Float64,2},data)
    λ = vec(convert(Array, λ))

    #pre emphasis filtering
    λ = λ .* preemph

    # compute fft and get power spectral density
    powspec = fftλ(λ, λsr, ϕl, ∇ϕ)

    ϕenergy = sum(powspec, dims=1)

    fbank, bin = computeFilterBanks(nfilt, computeϕl(λsr, ϕl), λsr)
    fbankDB = 20 * log10.(fbank * powspec)  # dB

    mfcc = mapslices(x->dct(x), fbankDB, dims=1)
    fmfcc = mfcc[2:num_ceps+1,:]
    ∇fmfcc = compute∇mffc(fmfcc, N)
    ∇∇fmfcc = compute∇mffc(∇fmfcc, N)

    return λsr, ϕl, powspec, bin, fbankDB, fmfcc, ∇fmfcc, ∇∇fmfcc
end

function myplot!(file, powspec, fbankDB, fmfcc, bin, λsr, ϕl; start=1, finish=0, colors="base")
  
  
    bin2freq(bin, λsr, ϕl) = [(i-1)*λsr/ϕl for i in 1:fld(ϕl,2)+1]
    ϕl = computeϕl(λsr, ϕl)
    binfreqs = bin2freq(bin, λsr, ϕl)

    maxi = findfirst(x->x==maximum(powspec[:,1]), powspec[:,1])
    maxHz = binfreqs[maxi]
  
  
    # beware, not the most elegant process you've ever seen.


    if colors == "base"
        if start == 1 && finish == 0
            l = @layout [a b; c d; e f]
            p1 = plot(title = file*" : "*string(round(maxHz)), binfreqs, powspec[:,1])
            p2 = plot(binfreqs, powspec[:,10])
            p3 = plot(binfreqs, powspec[:,20])
            p4 = plot(binfreqs, powspec[:,30])
            p5 = heatmap(fbankDB)
            p6 = heatmap(fmfcc)

            return plot(p1, p2, p3, p4, p5, p6, layout = l)
        else
            l = @layout [a b; c d; e f]

            p1 = plot(title = file*" : "*string(round(maxHz)), binfreqs, powspec[:,start])
            p2 = plot(binfreqs, powspec[:,start+10])
            p3 = plot(binfreqs, powspec[:,start+20])
            p4 = plot(powspec[:,start+30])
            p5 = heatmap(fbankDB[:,start:finish])
            p6 = heatmap(fmfcc[:,start:finish])

            return plot(p1, p2, p3, p4, p5, p6, layout = l)
        end
    else
        if start == 1 && finish == 0
            l = @layout [a b; c d; e f]

            p1 = plot(title = file*" : "*string(round(maxHz)), binfreqs, powspec[:,1])
            p2 = plot(binfreqs, powspec[:,10])
            p3 = plot(binfreqs, powspec[:,20])
            p4 = plot(binfreqs, powspec[:,30])
            p5 = heatmap(fbankDB, color=:coolwarm)
            p6 = heatmap(fmfcc, color=:coolwarm)

            return plot(p1, p2, p3, p4, p5, p6, layout = l)
        else
            l = @layout [a b; c d; e f]

            p1 = plot(title = file*" : "*string(round(maxHz)), binfreqs, powspec[:,start])
            p2 = plot(binfreqs, powspec[:,start+10])
            p3 = plot(binfreqs, powspec[:,start+20])
            p4 = plot(binfreqs, powspec[:,start+30])
            p5 = heatmap(fbankDB[:,start:finish], color=:coolwarm)
            p6 = heatmap(fmfcc[:,start:finish], color=:coolwarm)

            return plot(p1, p2, p3, p4, p5, p6, layout = l)
        end
    end
end


# Right, now just cd into folder with your wav file

cd()
cd("samples/")
a2 = "A2v16.wav"
c4 = "C4v8.5-PA.wav"
fs = "F#1v16.wav"

file = a2
file = c4
file = fs

# set file as file you wanna extract

λsr, ϕl, powspec, bin, fbankDB, fmfcc, ∇fmfcc, ∇∇fmfcc = generateFeatures(file, preemph = 0.97, ϕl = 0.025, ∇ϕ = 0.01, nfilt=20, num_ceps = 12, N = 2)
myplot!(file, powspec, fbankDB, fmfcc, bin, λsr, ϕl, start=1, finish=0, colors="warm")

heatmap(∇fmfcc[:,1:100])
heatmap(∇∇fmfcc[:,1:10])

# enjoy
