const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  const token = req.headers['authorization'];
  
  if (!token) {
    return res.status(403).json({ message: "Token tidak ditemukan!" });
  }

  try {
    const decoded = jwt.verify(token.split(' ')[1], 'kunci_rahasia'); // ganti dengan secret key Anda
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ message: "Token tidak valid!" });
  }
};

module.exports = { verifyToken }; 