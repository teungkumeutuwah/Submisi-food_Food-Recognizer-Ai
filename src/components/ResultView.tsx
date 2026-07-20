import React, { useState, useEffect } from "react";
import { ArrowLeft, Check, Leaf, AlertCircle, UtensilsCrossed, MapPin, Activity, ShieldCheck, Star, Volume2, VolumeX } from "lucide-react";
import { ScannedFood } from "../types";
import { MacroCard } from "./MacroCard";

interface ResultViewProps {
  foodItem: ScannedFood | null;
  loading: boolean;
  error: string;
  onBack: () => void;
}

export const ResultView: React.FC<ResultViewProps> = ({
  foodItem,
  loading,
  error,
  onBack,
}) => {
  const [isSpeaking, setIsSpeaking] = useState(false);

  useEffect(() => {
    return () => {
      if (typeof window !== "undefined" && window.speechSynthesis) {
        window.speechSynthesis.cancel();
      }
    };
  }, []);

  const handleToggleSpeech = () => {
    if (!foodItem || typeof window === "undefined" || !window.speechSynthesis) return;

    if (isSpeaking) {
      window.speechSynthesis.cancel();
      setIsSpeaking(false);
      return;
    }

    const text = `Hasil analisis makanan. Menu ini diidentifikasi sebagai ${foodItem.name}. ` +
      `Kandungan gizi terdiri dari: kalori sebesar ${foodItem.calories} kilo kalori, ` +
      `protein ${foodItem.protein} gram, karbohidrat ${foodItem.carbs} gram, ` +
      `dan lemak ${foodItem.fat} gram. ` +
      `Makanan ini bersertifikat ${foodItem.halalStatus || "Halal"}.`;

    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = "id-ID";
    utterance.rate = 0.9;

    utterance.onend = () => {
      setIsSpeaking(false);
    };

    utterance.onerror = () => {
      setIsSpeaking(false);
    };

    window.speechSynthesis.speak(utterance);
    setIsSpeaking(true);
  };

  if (loading) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center p-8 bg-white text-center">
        <div className="relative flex items-center justify-center">
          {/* Circular Spinner */}
          <div className="w-16 h-16 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
          <UtensilsCrossed size={24} className="absolute text-emerald-500 animate-pulse" />
        </div>
        <h2 className="text-lg font-extrabold text-gray-900 mt-6 animate-pulse">
          Menganalisis Makanan...
        </h2>
        <p className="text-xs text-gray-500 max-w-xs mt-2 leading-relaxed">
          Kecerdasan Buatan sedang menganalisis gambar untuk mengidentifikasi bahan, resep, dan info nutrisi secara mendalam.
        </p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center p-8 bg-white text-center">
        <div className="w-16 h-16 bg-red-50 text-red-500 rounded-full flex items-center justify-center mb-4 shadow-sm shadow-red-100">
          <AlertCircle size={32} />
        </div>
        <h2 className="text-lg font-bold text-gray-900">Terjadi Kesalahan</h2>
        <p className="text-xs text-red-500 max-w-xs mt-2 bg-red-50/50 p-3 rounded-xl border border-red-100 leading-relaxed font-medium">
          {error}
        </p>
        <button
          onClick={onBack}
          className="mt-6 px-6 py-2.5 bg-emerald-500 hover:bg-emerald-600 active:scale-98 text-white font-bold text-xs rounded-xl shadow-md shadow-emerald-100 transition-all cursor-pointer"
        >
          Kembali
        </button>
      </div>
    );
  }

  if (!foodItem) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center p-8 bg-white text-center">
        <p className="text-sm text-gray-500 font-medium">Tidak ada data pemindaian aktif</p>
        <button
          onClick={onBack}
          className="mt-4 px-5 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold text-xs rounded-xl transition-colors cursor-pointer"
        >
          Kembali ke Beranda
        </button>
      </div>
    );
  }

  const ingredientsList = foodItem.recipeIngredients
    ? foodItem.recipeIngredients.split("; ").filter(Boolean)
    : [];

  return (
    <div className="flex-1 flex flex-col bg-gray-50 overflow-y-auto pb-12">
      {/* Top Navbar */}
      <div className="sticky top-0 bg-white border-b border-gray-100 p-4 flex items-center justify-between shrink-0 z-10 shadow-xs">
        <div className="flex items-center">
          <button
            onClick={onBack}
            className="p-2 text-gray-700 hover:bg-gray-100 rounded-full transition-colors mr-3"
            aria-label="Kembali"
          >
            <ArrowLeft size={20} />
          </button>
          <h1 className="font-extrabold text-gray-900 text-base">Hasil Analisis Kuliner</h1>
        </div>
        {foodItem && (
          <button
            onClick={handleToggleSpeech}
            className={`px-3 py-1.5 rounded-full transition-all duration-300 flex items-center gap-1.5 cursor-pointer text-xs font-bold ${
              isSpeaking
                ? "bg-emerald-50 text-emerald-600 ring-2 ring-emerald-500/20 animate-pulse"
                : "text-gray-500 hover:bg-gray-100"
            }`}
            title={isSpeaking ? "Hentikan Suara" : "Dengarkan Analisis"}
          >
            {isSpeaking ? <VolumeX size={15} /> : <Volume2 size={15} />}
            <span>
              {isSpeaking ? "Membaca..." : "Suara AI"}
            </span>
          </button>
        )}
      </div>

      {/* Main Details Body */}
      <div className="flex-1 max-w-xl mx-auto w-full">
        {/* 1. Food Picture Header */}
        <div className="relative w-full h-64 bg-gray-900 overflow-hidden">
          {foodItem.imagePath ? (
            <img
              src={foodItem.imagePath}
              alt={foodItem.name}
              className="w-full h-full object-cover"
              referrerPolicy="no-referrer"
            />
          ) : foodItem.recipeThumb ? (
            <img
              src={foodItem.recipeThumb}
              alt={foodItem.name}
              className="w-full h-full object-cover"
              referrerPolicy="no-referrer"
            />
          ) : (
            <div className="w-full h-full bg-emerald-500/10 flex items-center justify-center">
              <UtensilsCrossed size={64} className="text-emerald-500/30" />
            </div>
          )}

          {/* Dark picture bottom gradient overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/75 via-black/30 to-transparent"></div>

          {/* Overlapping floating card */}
          <div className="absolute bottom-4 left-4 right-4 bg-white/95 backdrop-blur-xs p-4 rounded-2xl border border-gray-100/50 shadow-lg flex items-center justify-between">
            <div className="flex-1 min-w-0 pr-4">
              <h2 className="text-lg font-black text-gray-900 truncate leading-tight">
                {foodItem.name}
              </h2>
              {/* Scientific name label */}
              <span className="text-xs font-semibold text-emerald-600 mt-1 block italic">
                {foodItem.scientificName || "Cibus deliciosis"}
              </span>
            </div>

            {/* Confidence progress */}
            <div className="flex flex-col items-end shrink-0">
              <span className="text-lg font-black text-emerald-600 leading-none mb-1">
                {Math.round(foodItem.confidence * 100)}%
              </span>
              <div className="w-16 h-1.5 bg-emerald-50 rounded-full overflow-hidden">
                <div
                  className="h-full bg-emerald-500"
                  style={{ width: `${foodItem.confidence * 100}%` }}
                ></div>
              </div>
              <span className="text-[9px] text-gray-400 mt-0.5 font-bold uppercase tracking-wider">Akurasi AI</span>
            </div>
          </div>
        </div>

        {/* 2. Scientific Name & Halal Status Badges */}
        <div className="mt-4 px-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
          {/* Scientific Name Card */}
          <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-xs flex items-center gap-3">
            <div className="w-10 h-10 bg-sky-50 rounded-xl flex items-center justify-center text-sky-500 shrink-0">
              <Leaf size={20} />
            </div>
            <div>
              <span className="text-[9px] font-black text-gray-400 uppercase tracking-wider block">Nama Ilmiah</span>
              <span className="text-sm font-bold text-gray-800 italic block">
                {foodItem.scientificName || "Cibus deliciosis"}
              </span>
            </div>
          </div>

          {/* Halal Status Card */}
          <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-xs flex items-center gap-3">
            <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${
              foodItem.halalStatus === "Halal" ? "bg-emerald-50 text-emerald-600" :
              foodItem.halalStatus === "Syubhah" ? "bg-amber-50 text-amber-600" :
              "bg-red-50 text-red-600"
            }`}>
              <ShieldCheck size={22} />
            </div>
            <div>
              <span className="text-[9px] font-black text-gray-400 uppercase tracking-wider block">Sertifikasi Halal</span>
              <div className="flex items-center gap-1.5">
                <span className={`text-sm font-black ${
                  foodItem.halalStatus === "Halal" ? "text-emerald-600" :
                  foodItem.halalStatus === "Syubhah" ? "text-amber-600" :
                  "text-red-600"
                }`}>
                  {foodItem.halalStatus || "Halal"}
                </span>
                <span className="text-[10px] text-gray-400 font-bold bg-gray-100 px-1.5 py-0.5 rounded-md">MUI</span>
              </div>
            </div>
          </div>
        </div>

        {/* Halal Explanation banner */}
        {foodItem.halalReason && (
          <div className="mt-3 mx-4 bg-emerald-50/40 border border-emerald-100 p-3.5 rounded-2xl text-xs text-gray-600 leading-relaxed shadow-3xs">
            <strong className="text-emerald-700 font-bold block mb-0.5">Analisis Titik Kritis Halal:</strong>
            {foodItem.halalReason}
          </div>
        )}

        {/* 3. Nutrition Section */}
        <div className="mt-6 px-4">
          <h3 className="text-xs font-black tracking-wider text-emerald-600 uppercase mb-3">
            Kandungan Gizi & Nutrisi
          </h3>

          <div className="flex gap-2">
            <MacroCard
              label="KALORI"
              value={`${foodItem.calories}`}
              labelColor="text-emerald-500"
              valueColor="text-emerald-600 text-lg"
              emoji="🔥"
            />
            <MacroCard
              label="PROTEIN"
              value={`${foodItem.protein}g`}
              labelColor="text-gray-400"
              valueColor="text-gray-900 text-sm"
              emoji="🍗"
            />
            <MacroCard
              label="KARBO"
              value={`${foodItem.carbs}g`}
              labelColor="text-gray-400"
              valueColor="text-gray-900 text-sm"
              emoji="🍞"
            />
            <MacroCard
              label="LEMAK"
              value={`${foodItem.fat}g`}
              labelColor="text-gray-400"
              valueColor="text-gray-900 text-sm"
              emoji="🥑"
            />
          </div>

          {/* Fiber badge */}
          {foodItem.fiber > 0 && (
            <div className="mt-3 bg-white rounded-xl border border-gray-100 p-3 flex items-center justify-between shadow-xs">
              <div className="flex items-center text-xs font-semibold text-gray-700">
                <Leaf size={16} className="text-emerald-500 mr-2 shrink-0" />
                <span>Serat Makanan (Fiber)</span>
              </div>
              <span className="text-sm font-bold text-emerald-600">{foodItem.fiber}g</span>
            </div>
          )}

          {/* Graphic Visualization Card */}
          <div className="mt-4 bg-white rounded-2xl border border-gray-100 p-4 shadow-xs">
            <h4 className="text-xs font-black text-gray-700 tracking-wide mb-3 flex items-center gap-1.5">
              <span>📊</span> Grafik Distribusi Kalori & Makronutrisi
            </h4>

            <div className="flex flex-col sm:flex-row items-center gap-6 py-2">
              {/* Left Column: Donut SVG Chart */}
              <div className="relative w-36 h-36 shrink-0 flex items-center justify-center">
                <svg
                  viewBox="0 0 100 100"
                  className="w-full h-full transform -rotate-90"
                >
                  {/* Background Track */}
                  <circle
                    cx="50"
                    cy="50"
                    r={38}
                    fill="transparent"
                    stroke="#f9fafb"
                    strokeWidth={9}
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r={38}
                    fill="transparent"
                    stroke="#f3f4f6"
                    strokeWidth={8}
                  />

                  {/* SVG Chained Segments */}
                  {(() => {
                    const pGrams = foodItem.protein || 0;
                    const cGrams = foodItem.carbs || 0;
                    const fGrams = foodItem.fat || 0;
                    const totalGrams = pGrams + cGrams + fGrams;

                    if (totalGrams === 0) {
                      return (
                        <circle
                          cx="50"
                          cy="50"
                          r={38}
                          fill="transparent"
                          stroke="#e5e7eb"
                          strokeWidth={8}
                        />
                      );
                    }

                    const pPct = (pGrams / totalGrams) * 100;
                    const cPct = (cGrams / totalGrams) * 100;
                    const fPct = (fGrams / totalGrams) * 100;

                    const segments = [
                      { pct: pPct, color: "#f97316" }, // Protein - Orange-500
                      { pct: cPct, color: "#eab308" }, // Carbs - Yellow-500
                      { pct: fPct, color: "#10b981" }, // Fat - Emerald-500
                    ];

                    const radius = 38;
                    const circumference = 2 * Math.PI * radius; // ~238.76
                    let localAccumulated = 0;

                    return segments.map((segment, index) => {
                      if (segment.pct === 0) return null;
                      const strokeDash = (segment.pct / 100) * circumference;
                      const strokeOffset = circumference - (localAccumulated / 100) * circumference;
                      localAccumulated += segment.pct;

                      return (
                        <circle
                          key={index}
                          cx="50"
                          cy="50"
                          r={radius}
                          fill="transparent"
                          stroke={segment.color}
                          strokeWidth={8}
                          strokeDasharray={`${strokeDash} ${circumference}`}
                          strokeDashoffset={strokeOffset}
                          className="transition-all duration-700 ease-out origin-center"
                          style={{
                            transformOrigin: "50px 50px",
                          }}
                        />
                      );
                    });
                  })()}
                </svg>

                {/* Floating Absolute Center Text */}
                <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                  <span className="text-xl font-black text-gray-900 leading-none">
                    {foodItem.calories}
                  </span>
                  <span className="text-[10px] font-black text-gray-400 tracking-wider uppercase mt-0.5">
                    kkal
                  </span>
                </div>
              </div>

              {/* Right Column: Breakdown List */}
              <div className="flex-1 w-full space-y-3">
                {(() => {
                  const pGrams = foodItem.protein || 0;
                  const cGrams = foodItem.carbs || 0;
                  const fGrams = foodItem.fat || 0;
                  const totalGrams = pGrams + cGrams + fGrams;

                  const pPct = totalGrams > 0 ? (pGrams / totalGrams) * 100 : 0;
                  const cPct = totalGrams > 0 ? (cGrams / totalGrams) * 100 : 0;
                  const fPct = totalGrams > 0 ? (fGrams / totalGrams) * 100 : 0;

                  const pKcal = pGrams * 4;
                  const cKcal = cGrams * 4;
                  const fKcal = fGrams * 9;
                  const totalKcal = pKcal + cKcal + fKcal;

                  const segments = [
                    {
                      name: "Protein",
                      grams: pGrams,
                      pct: pPct,
                      kcal: pKcal,
                      bgColor: "bg-orange-500",
                      emoji: "Protein 🍗"
                    },
                    {
                      name: "Karbohidrat",
                      grams: cGrams,
                      pct: cPct,
                      kcal: cKcal,
                      bgColor: "bg-yellow-500",
                      emoji: "Karbohidrat 🍞"
                    },
                    {
                      name: "Lemak",
                      grams: fGrams,
                      pct: fPct,
                      kcal: fKcal,
                      bgColor: "bg-emerald-500",
                      emoji: "Lemak 🥑"
                    }
                  ];

                  return segments.map((segment, index) => {
                    const percentOfMass = Math.round(segment.pct);
                    const caloriePct = totalKcal > 0 ? Math.round((segment.kcal / totalKcal) * 100) : 0;

                    return (
                      <div key={index} className="space-y-1">
                        <div className="flex items-center justify-between text-xs">
                          <div className="flex items-center font-bold text-gray-800 gap-1.5">
                            <span className={`w-2.5 h-2.5 rounded-full ${segment.bgColor}`} />
                            <span>{segment.emoji}</span>
                          </div>
                          <div className="text-right text-gray-900 font-extrabold">
                            {segment.grams}g <span className="text-[10px] text-gray-400 font-normal">({percentOfMass}%)</span>
                          </div>
                        </div>

                        {/* Custom Track and Progress bar */}
                        <div className="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
                          <div
                            className={`h-full ${segment.bgColor} transition-all duration-700 ease-out`}
                            style={{ width: `${percentOfMass}%` }}
                          />
                        </div>

                        {/* Energy contributions */}
                        <div className="flex justify-between text-[10px] text-gray-500 font-medium px-0.5">
                          <span>Kontribusi Kalori:</span>
                          <span className="font-bold text-gray-700">
                            {segment.kcal} kkal ({caloriePct}%)
                          </span>
                        </div>
                      </div>
                    );
                  });
                })()}
              </div>
            </div>

            {/* Quick energy disclaimer / info tip */}
            <div className="mt-3 pt-3 border-t border-gray-50 flex items-center justify-between text-[10px] text-gray-400 font-medium">
              <span>Standard: 1g Protein/Karbo = 4 kkal • 1g Lemak = 9 kkal</span>
              <span className="text-emerald-500 font-semibold">Gizi Seimbang ⚖️</span>
            </div>
          </div>
        </div>

        {/* 4. Health & Nutrition Analysis Block */}
        <div className="mt-6 px-4">
          <h3 className="text-xs font-black tracking-wider text-rose-500 uppercase mb-3 flex items-center gap-1.5">
            <Activity size={16} />
            <span>1. Analisis Kesehatan & Gizi</span>
          </h3>
          <div className="bg-rose-50/25 rounded-2xl border border-rose-100/60 p-4 shadow-xs">
            <p className="text-xs text-gray-700 leading-relaxed font-semibold">
              {foodItem.healthAnalysis || "Masakan ini menyajikan kombinasi zat gizi esensial yang sangat penting untuk mendukung tingkat metabolisme dan kebugaran fisik harian Anda. Konsumsi sewajarnya sebagai bagian dari diet seimbang harian."}
            </p>
          </div>
        </div>

        {/* 5. Places to Buy (Nearby Restaurant Search) */}
        <div className="mt-6 px-4">
          <h3 className="text-xs font-black tracking-wider text-sky-600 uppercase mb-3 flex items-center gap-1.5">
            <MapPin size={16} />
            <span>2. Cek Tempat yang Menjual Makanan Ini</span>
          </h3>
          <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-xs space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-gray-50">
              <div className="min-w-0 pr-4">
                <h4 className="text-xs font-black text-gray-800">Cari Sekitar Anda</h4>
                <p className="text-[10px] text-gray-400 mt-0.5">Dapatkan penunjuk arah langsung di Google Maps</p>
              </div>
              <a
                href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(foodItem.name + ' terdekat')}`}
                target="_blank"
                rel="noopener noreferrer"
                className="shrink-0 flex items-center gap-1.5 px-3 py-2 bg-sky-500 hover:bg-sky-600 text-white rounded-xl text-xs font-black shadow-xs transition-colors cursor-pointer"
              >
                <span>Cari di Peta</span>
              </a>
            </div>

            {/* Recommendations List */}
            <div className="space-y-3">
              <span className="text-[9px] font-black text-gray-400 uppercase tracking-wider block">Rekomendasi Restoran Populer</span>
              {foodItem.suggestedRestaurants && foodItem.suggestedRestaurants.length > 0 ? (
                <div className="space-y-2.5">
                  {foodItem.suggestedRestaurants.map((restaurant, idx) => (
                    <div
                      key={idx}
                      className="flex items-start justify-between p-3 rounded-xl border border-gray-50 hover:bg-gray-50/50 transition-colors"
                    >
                      <div className="min-w-0 pr-3">
                        <h5 className="text-xs font-bold text-gray-800 truncate">
                          {restaurant.name}
                        </h5>
                        <p className="text-[10px] text-gray-400 truncate mt-0.5">
                          {restaurant.address}
                        </p>
                      </div>
                      <div className="shrink-0 flex flex-col items-end gap-1.5">
                        {restaurant.rating && (
                          <div className="flex items-center gap-1 bg-amber-50 text-amber-600 px-1.5 py-0.5 rounded-md text-[10px] font-black">
                            <Star size={10} className="fill-amber-500 text-amber-500" />
                            <span>{restaurant.rating.toFixed(1)}</span>
                          </div>
                        )}
                        <a
                          href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(restaurant.name + ' ' + restaurant.address)}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="text-[9px] font-black text-sky-600 hover:underline"
                        >
                          Rute Jalan ↗
                        </a>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-4 text-gray-400 text-xs">
                  Saran restoran tidak tersedia. Silakan gunakan tombol "Cari di Peta" di atas untuk mencari secara langsung.
                </div>
              )}
            </div>
          </div>
        </div>

        {/* 6. Recipe Section */}
        <div className="mt-6 px-4">
          <h3 className="text-xs font-black tracking-wider text-amber-600 uppercase mb-3 flex items-center gap-1.5">
            <UtensilsCrossed size={16} />
            <span>3. Resep & Cara Memasak</span>
          </h3>

          {foodItem.hasRecipe ? (
            <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-xs">
              <div className="flex items-center mb-4 pb-4 border-b border-gray-50">
                {foodItem.recipeThumb ? (
                  <img
                    src={foodItem.recipeThumb}
                    alt={foodItem.recipeTitle}
                    className="w-12 h-12 rounded-lg object-cover shrink-0 border border-gray-100"
                    referrerPolicy="no-referrer"
                  />
                ) : (
                  <div className="w-12 h-12 bg-amber-50 text-amber-500 rounded-lg flex items-center justify-center shrink-0 border border-amber-100">
                    <UtensilsCrossed size={20} />
                  </div>
                )}
                <div className="ml-3 min-w-0">
                  <h4 className="text-sm font-bold text-gray-900 truncate">
                    {foodItem.recipeTitle}
                  </h4>
                  <span className="text-[10px] font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full inline-block mt-0.5">
                    Resep & Langkah Siap
                  </span>
                </div>
              </div>

              {/* Ingredients block */}
              {ingredientsList.length > 0 && (
                <div className="mb-4">
                  <h5 className="text-xs font-extrabold text-gray-800 mb-2">Bahan-bahan:</h5>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-1.5">
                    {ingredientsList.map((ing, idx) => (
                      <div key={idx} className="flex items-center text-xs text-gray-600">
                        <Check size={14} className="text-emerald-500 mr-2 shrink-0" />
                        <span className="truncate">{ing}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Instructions steps */}
              {foodItem.recipeInstructions && (
                <div className="mt-4 pt-4 border-t border-gray-50">
                  <h5 className="text-xs font-extrabold text-gray-800 mb-2">
                    Langkah Pembuatan:
                  </h5>
                  <p className="text-xs text-gray-600 leading-relaxed whitespace-pre-line">
                    {foodItem.recipeInstructions}
                  </p>
                </div>
              )}
            </div>
          ) : (
            <div className="bg-white rounded-2xl border border-gray-100 p-6 shadow-xs text-center">
              <div className="w-10 h-10 bg-gray-50 text-gray-400 rounded-full flex items-center justify-center mx-auto mb-3">
                <UtensilsCrossed size={18} />
              </div>
              <h4 className="text-xs font-bold text-gray-700">Resep Tidak Ditemukan</h4>
              <p className="text-[11px] text-gray-400 mt-1 max-w-xs mx-auto leading-relaxed">
                Tidak dapat menemukan atau menyusun resep untuk "{foodItem.name}".
                Silakan coba memindai makanan umum lainnya.
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Floating Action Button for Text-to-Speech */}
      {foodItem && (
        <button
          onClick={handleToggleSpeech}
          className={`fixed bottom-6 right-6 z-50 px-4 py-3.5 rounded-full shadow-2xl transition-all duration-300 hover:scale-110 active:scale-95 cursor-pointer flex items-center justify-center gap-2 border border-white/20 ${
            isSpeaking
              ? "bg-rose-500 text-white hover:bg-rose-600 shadow-rose-500/30 animate-pulse"
              : "bg-emerald-600 text-white hover:bg-emerald-700 shadow-emerald-600/30"
          }`}
          title={isSpeaking ? "Hentikan Suara" : "Dengarkan Analisis Makanan (TTS)"}
        >
          {isSpeaking ? (
            <>
              <VolumeX size={18} />
              <span className="text-xs font-extrabold tracking-wide uppercase">Stop Suara</span>
            </>
          ) : (
            <>
              <Volume2 size={18} className="animate-bounce" />
              <span className="text-xs font-extrabold tracking-wide uppercase">Dengar AI</span>
            </>
          )}
        </button>
      )}
    </div>
  );
};

