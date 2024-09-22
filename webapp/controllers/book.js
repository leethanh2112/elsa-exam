/**
 * GET /books
 * List all books.
 */
const Book = require('../models/Book.js');

exports.readBooks = async (req, res) => {
    try {
      const books = await Book.find(); // no callback needed
      res.render('books', { books });
    } catch (err) {
      res.status(500).send(err.message);
    }
  };

exports.createBooks = async (req, res) => {
  try {
    const books = await Book.find(); // no callback needed
    res.render('books', { books });
  } catch (err) {
    res.status(500).send(err.message);
  }
};

exports.updateBooks = async (req, res) => {
    try {
      const books = await Book.find(); // no callback needed
      res.render('books', { books });
    } catch (err) {
      res.status(500).send(err.message);
    }
  };

exports.deleteBooks = async (req, res) => {
    try {
      const books = await Book.find(); // no callback needed
      res.render('books', { books });
    } catch (err) {
      res.status(500).send(err.message);
    }
  };
