-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Waktu pembuatan: 18 Jan 2025 pada 19.37
-- Versi server: 10.6.20-MariaDB-cll-lve
-- Versi PHP: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `nhllchxk_ssb`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `aspect`
--

CREATE TABLE `aspect` (
  `id_aspect` int(11) NOT NULL,
  `name_aspect` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `aspect`
--

INSERT INTO `aspect` (`id_aspect`, `name_aspect`) VALUES
(1, 'Aspek Teknis'),
(2, 'Aspek Fisik'),
(3, 'Aspek Taktis'),
(4, 'Aspek Mental'),
(5, 'Aspek Sosial'),
(6, 'Aspek Kesenangan');

-- --------------------------------------------------------

--
-- Struktur dari tabel `aspect_sub`
--

CREATE TABLE `aspect_sub` (
  `id_aspect_sub` int(11) NOT NULL,
  `id_aspect` int(11) NOT NULL,
  `name_aspect_sub` varchar(40) NOT NULL,
  `ket_aspect_sub` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `aspect_sub`
--

INSERT INTO `aspect_sub` (`id_aspect_sub`, `id_aspect`, `name_aspect_sub`, `ket_aspect_sub`) VALUES
(1, 1, 'Kontrol Bola', 'Kemampuan mendasar untuk mengontrol bola dengan kaki, dada, atau bagian tubuh lain yang diperbolehkan.'),
(2, 1, 'Dribbling', 'Kemampuan menggiring bola dengan kecepatan dan kontrol dalam situasi permainan.'),
(3, 1, 'Passing dan Receiving', 'Akurasi dan kemampuan menerima bola dalam berbagai situasi.'),
(4, 1, 'Shooting', 'Ketepatan dan kekuatan tendangan, baik untuk mencetak gol maupun umpan jauh.'),
(5, 1, '1v1 Skills', 'Kemampuan individu untuk melewati lawan atau bertahan saat menghadapi duel satu lawan satu.'),
(6, 2, 'Kelincahan (Agility)', 'Kecepatan dalam bergerak, berbelok, atau mengubah arah.'),
(7, 2, 'Kecepatan (Speed)', 'Akselerasi dan kecepatan dalam jarak pendek maupun panjang.'),
(8, 2, 'Keseimbangan (Balance)', 'Stabilitas tubuh dalam situasi dinamis atau duel fisik.'),
(9, 2, 'Koordinasi (Coordination)', 'Kemampuan mengontrol tubuh saat berinteraksi dengan bola.'),
(10, 2, 'Daya Tahan (Endurance)', 'Ketahanan fisik sesuai kebutuhan usia.'),
(11, 3, 'Awareness (Kesadaran Lapangan)', 'Kemampuan membaca situasi permainan dan posisi rekan/lawan.'),
(12, 3, 'Positioning', 'Memahami posisi yang tepat dalam menyerang maupun bertahan.'),
(13, 3, 'Decision-Making', 'Mengambil keputusan yang tepat, seperti kapan mengoper, menggiring, atau menembak.'),
(14, 3, 'Teamwork', 'Kesadaran akan peran dalam tim dan kontribusi terhadap kerja sama tim.'),
(15, 4, 'Motivasi', 'Semangat untuk berlatih dan bermain.'),
(16, 4, 'Resilience', 'Ketahanan menghadapi kekalahan atau kesalahan.'),
(17, 4, 'Focus and Concentration', 'Kemampuan untuk tetap fokus selama pertandingan atau latihan.'),
(18, 4, 'Fair Play', 'Menunjukkan sportivitas dan menghormati lawan, rekan, serta wasit.'),
(19, 4, 'Kepercayaan Diri (Self-Confidence)', 'Percaya pada kemampuan diri sendiri, tanpa takut membuat kesalahan.'),
(20, 5, 'Kerja Sama Tim', 'Kemampuan berkolaborasi dengan rekan setim.'),
(21, 5, 'Komunikasi', 'Berinteraksi efektif dengan tim, baik verbal maupun non-verbal.'),
(22, 5, 'Kepemimpinan (Leadership)', 'Mengambil inisiatif atau membantu tim tetap terorganisir.'),
(23, 5, 'Respect (Penghormatan)', 'Sikap hormat terhadap pemain lain, pelatih, dan ofisial.'),
(24, 6, 'Antusiasme Bermain', 'Anak-anak yang senang bermain akan lebih cepat berkembang.'),
(25, 6, 'Kemajuan Individu', 'Fokus pada perkembangan masing-masing anak, bukan membandingkan dengan orang lain.'),
(26, 5, 'Cinta Sepak Bola', 'Menumbuhkan minat dan kebiasaan bermain sepak bola di masa depan.');

-- --------------------------------------------------------

--
-- Struktur dari tabel `assessment`
--

CREATE TABLE `assessment` (
  `id_assessment` int(11) NOT NULL,
  `year_academic` varchar(9) NOT NULL,
  `year_assessment` varchar(4) NOT NULL,
  `reg_id_student` int(11) NOT NULL,
  `id_aspect_sub` int(11) NOT NULL,
  `id_coach` int(11) NOT NULL,
  `point` int(3) NOT NULL,
  `ket` text NOT NULL,
  `date_assessment` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `assessment`
--

INSERT INTO `assessment` (`id_assessment`, `year_academic`, `year_assessment`, `reg_id_student`, `id_aspect_sub`, `id_coach`, `point`, `ket`, `date_assessment`) VALUES
(8, '2223', '222', 1, 1, 1, 100, 'j', '0000-00-00'),
(9, '2013', '2015', 15, 1, 1, 1000, 'baik', '2025-01-10');

-- --------------------------------------------------------

--
-- Struktur dari tabel `assessment_setting`
--

CREATE TABLE `assessment_setting` (
  `id_assessment_setting` int(11) NOT NULL,
  `year_academic` varchar(9) NOT NULL,
  `year_assessment` varchar(4) NOT NULL,
  `id_coach` int(11) NOT NULL,
  `id_aspect_sub` int(11) NOT NULL,
  `bobot` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `assessment_setting`
--

INSERT INTO `assessment_setting` (`id_assessment_setting`, `year_academic`, `year_assessment`, `id_coach`, `id_aspect_sub`, `bobot`) VALUES
(1, '2025/2026', '2013', 1, 1, 10),
(2, '2025/2026', '2013', 1, 2, 5);

-- --------------------------------------------------------

--
-- Struktur dari tabel `coach`
--

CREATE TABLE `coach` (
  `id_coach` int(11) NOT NULL,
  `name_coach` varchar(30) NOT NULL,
  `coach_department` varchar(30) NOT NULL,
  `years_coach` varchar(4) NOT NULL,
  `email` varchar(30) NOT NULL,
  `nohp` varchar(15) NOT NULL,
  `status_coach` int(1) NOT NULL,
  `license` varchar(100) NOT NULL,
  `experience` text NOT NULL,
  `achievements` text NOT NULL,
  `photo` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `coach`
--

INSERT INTO `coach` (`id_coach`, `name_coach`, `coach_department`, `years_coach`, `email`, `nohp`, `status_coach`, `license`, `experience`, `achievements`, `photo`) VALUES
(1, 'Suganda', 'Coach Under 11-12', '2013', '', '', 1, '', '', '', ''),
(4, 'poyy', 'U-8', '88', 'pyy', '54', 1, 'AFC C', 'yggd', 'xc', 'uploads/coach/coach-1736275731447-104555988.jpg'),
(5, 'muhamad badru duja', 'Senior', '30', 'badru@gmail.com', '123', 1, 'UEFA A', 'banyak', 'banyak', 'uploads/coach/coach-1736483108564-19611523.jpg'),
(6, 'egi', 'U-14', '1', 'egiapriliansyah5@gmail.com', '08123', 1, 'UEFA A', '1', '1', 'uploads/coach/coach-1736491255105-385520455.jpg'),
(7, 'luis miya', 'Senior', '56', 'luis@gmail.com', '123', 1, 'AFC A', 'ngelatih timnas 3 tahun \nngelatih barca', 'juara dunia\nucl\ncopa del rey', 'uploads/coach/coach-1736496484485-132674253.jpg'),
(8, 'luis miya', 'Senior', '50', 'l@gmail.com', '123', 1, 'AFC Pro', 'banyak', 'banyak', 'uploads/coach/coach-1736496516904-218362646.jpg');

-- --------------------------------------------------------

--
-- Struktur dari tabel `departement`
--

CREATE TABLE `departement` (
  `id_departement` int(11) NOT NULL,
  `name_departement` varchar(30) NOT NULL,
  `status` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `departement`
--

INSERT INTO `departement` (`id_departement`, `name_departement`, `status`) VALUES
(1, 'A', 1),
(2, 'B', 1),
(3, 'C', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `information`
--

CREATE TABLE `information` (
  `id_information` int(11) NOT NULL,
  `name_info` varchar(50) NOT NULL,
  `info` text NOT NULL,
  `date_info` date NOT NULL,
  `status_info` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `information`
--

INSERT INTO `information` (`id_information`, `name_info`, `info`, `date_info`, `status_info`) VALUES
(3, 'ngopi', 'kuyy', '1899-11-29', 1),
(10, 'hshs', 'bshsh', '0000-00-00', 1),
(11, 'Sparing', 'Berhadiah', '0000-00-00', 1),
(12, 'hai', 'gs', '0000-00-00', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `management`
--

CREATE TABLE `management` (
  `id_management` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `gender` char(1) NOT NULL,
  `date_birth` date NOT NULL,
  `email` varchar(30) NOT NULL,
  `nohp` varchar(15) NOT NULL,
  `departement` int(11) NOT NULL,
  `status` int(1) NOT NULL,
  `photo` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `management`
--

INSERT INTO `management` (`id_management`, `name`, `gender`, `date_birth`, `email`, `nohp`, `departement`, `status`, `photo`) VALUES
(1, 'syahwal', 'L', '2025-01-09', 'syahwal@gmail.com', '08123', 1, 1, ''),
(6, 'wall', 'M', '2025-01-10', 's@', '1', 1, 1, 'uploads/student/student-1736495814068-695562221.jpg');

-- --------------------------------------------------------

--
-- Struktur dari tabel `point_rate`
--

CREATE TABLE `point_rate` (
  `id_point_rate` int(11) NOT NULL,
  `point_rate` int(3) NOT NULL,
  `rate` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `point_rate`
--

INSERT INTO `point_rate` (`id_point_rate`, `point_rate`, `rate`) VALUES
(1, 90, 'Luar Biasa (Exceptional)'),
(2, 70, 'Di Atas Rata-Rata (Above Avera'),
(3, 50, 'Rata-Rata (Average)'),
(4, 30, 'Perlu Peningkatan (Needs Impro'),
(5, 10, 'Sangat Membutuhkan Peningkatan');

-- --------------------------------------------------------

--
-- Struktur dari tabel `schedule`
--

CREATE TABLE `schedule` (
  `id_schedule` int(11) NOT NULL,
  `name_schedule` varchar(50) NOT NULL,
  `date_schedule` date NOT NULL,
  `waktu_bermain` int(11) NOT NULL,
  `nama_lapangan` varchar(255) NOT NULL,
  `nama_pertandingan` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `schedule`
--

INSERT INTO `schedule` (`id_schedule`, `name_schedule`, `date_schedule`, `waktu_bermain`, `nama_lapangan`, `nama_pertandingan`) VALUES
(2, 'madrid VS barca', '2025-01-23', 90, 'camp nou', 'elclasico'),
(5, 'badru VS pyy', '2025-01-10', 15, 'ring tinju', 'byon combat'),
(6, 'INDONESIA VS TIGER', '2025-01-15', 90, 'Glora Bung Karno (GBK)', 'Final word cup');

-- --------------------------------------------------------

--
-- Struktur dari tabel `student`
--

CREATE TABLE `student` (
  `reg_id_student` int(11) NOT NULL,
  `id_student` varchar(8) NOT NULL,
  `name` varchar(50) NOT NULL,
  `date_birth` varchar(100) NOT NULL,
  `gender` char(1) NOT NULL,
  `photo` varchar(100) NOT NULL,
  `email` varchar(50) NOT NULL,
  `nohp` varchar(15) NOT NULL,
  `registration_date` date NOT NULL,
  `status` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `student`
--

INSERT INTO `student` (`reg_id_student`, `id_student`, `name`, `date_birth`, `gender`, `photo`, `email`, `nohp`, `registration_date`, `status`) VALUES
(1, 'YRA1222', 'refa', '2003-10-10', 'L', 'uploads/student/student_1_1736433341283.jpeg', 'refafatur97@gmail.com', '124', '2022-12-24', 1),
(5, '1', 'Muhammad Refa Faturrahman', '2004-07-16', 'M', '', 'refafatur97@gmail.com', '081317490001', '2025-01-10', 1),
(6, '7', 'Egi Apriliansyah', '2004-04-10', 'M', '', 'egiapriliansyah5@gmail.com', '081388603049', '2025-01-10', 1),
(7, '10', 'Muhamad Syahwal Alfahri', '2003-06-06', 'M', '', 'm.syahwal56@gmail.com', '089655268700', '2025-01-10', 1),
(8, '3', 'Muhammad Badru Duju Hasyim Dahdori', '2004-09-12', 'M', '', 'badruduja226@gmail.com', '08382376424', '2025-01-10', 1);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `aspect`
--
ALTER TABLE `aspect`
  ADD PRIMARY KEY (`id_aspect`);

--
-- Indeks untuk tabel `aspect_sub`
--
ALTER TABLE `aspect_sub`
  ADD PRIMARY KEY (`id_aspect_sub`);

--
-- Indeks untuk tabel `assessment`
--
ALTER TABLE `assessment`
  ADD PRIMARY KEY (`id_assessment`);

--
-- Indeks untuk tabel `assessment_setting`
--
ALTER TABLE `assessment_setting`
  ADD PRIMARY KEY (`id_assessment_setting`);

--
-- Indeks untuk tabel `coach`
--
ALTER TABLE `coach`
  ADD PRIMARY KEY (`id_coach`);

--
-- Indeks untuk tabel `departement`
--
ALTER TABLE `departement`
  ADD PRIMARY KEY (`id_departement`);

--
-- Indeks untuk tabel `information`
--
ALTER TABLE `information`
  ADD PRIMARY KEY (`id_information`);

--
-- Indeks untuk tabel `management`
--
ALTER TABLE `management`
  ADD PRIMARY KEY (`id_management`);

--
-- Indeks untuk tabel `point_rate`
--
ALTER TABLE `point_rate`
  ADD PRIMARY KEY (`id_point_rate`);

--
-- Indeks untuk tabel `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`id_schedule`);

--
-- Indeks untuk tabel `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`reg_id_student`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `aspect`
--
ALTER TABLE `aspect`
  MODIFY `id_aspect` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `aspect_sub`
--
ALTER TABLE `aspect_sub`
  MODIFY `id_aspect_sub` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT untuk tabel `assessment`
--
ALTER TABLE `assessment`
  MODIFY `id_assessment` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `assessment_setting`
--
ALTER TABLE `assessment_setting`
  MODIFY `id_assessment_setting` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `coach`
--
ALTER TABLE `coach`
  MODIFY `id_coach` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `departement`
--
ALTER TABLE `departement`
  MODIFY `id_departement` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `information`
--
ALTER TABLE `information`
  MODIFY `id_information` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `management`
--
ALTER TABLE `management`
  MODIFY `id_management` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `point_rate`
--
ALTER TABLE `point_rate`
  MODIFY `id_point_rate` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `schedule`
--
ALTER TABLE `schedule`
  MODIFY `id_schedule` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `student`
--
ALTER TABLE `student`
  MODIFY `reg_id_student` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
