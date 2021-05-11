package simpledb;

import java.io.*;
import java.util.*;

/**
 * HeapFile is an implementation of a DbFile that stores a collection of tuples
 * in no particular order. Tuples are stored on pages, each of which is a fixed
 * size, and the file is simply a collection of those pages. HeapFile works
 * closely with HeapPage. The format of HeapPages is described in the HeapPage
 * constructor.
 * 
 * @see simpledb.HeapPage#HeapPage
 * @author Sam Madden
 */
public class HeapFile implements DbFile {

    private File file;
    private int id;
    private TupleDesc td;

    /**
     * Constructs a heap file backed by the specified file.
     * 
     * @param f
     *            the file that stores the on-disk backing store for this heap
     *            file.
     */
    public HeapFile(File f, TupleDesc td) {
        // some code goes here
        this.file = f;
        this.td = td;
        this.id = this.file.hashCode();
    }

    /**
     * Returns the File backing this HeapFile on disk.
     * 
     * @return the File backing this HeapFile on disk.
     */
    public File getFile() {
        // some code goes here
        return this.file;
    }

    /**
     * Returns an ID uniquely identifying this HeapFile. Implementation note:
     * you will need to generate this tableid somewhere ensure that each
     * HeapFile has a "unique id," and that you always return the same value for
     * a particular HeapFile. We suggest hashing the absolute file name of the
     * file underlying the heapfile, i.e. f.getAbsoluteFile().hashCode().
     * 
     * @return an ID uniquely identifying this HeapFile.
     */
    public int getId() {
        // some code goes here
        return this.id;
    }

    /**
     * Returns the TupleDesc of the table stored in this DbFile.
     * 
     * @return TupleDesc of this DbFile.
     */
    public TupleDesc getTupleDesc() {
        // some code goes here
        return this.td;
    }

    // see DbFile.java for javadocs
    public Page readPage(PageId pid) {
        // some code goes here
        try {
            RandomAccessFile raf = new RandomAccessFile(this.file, "r");
            raf.seek(BufferPool.PAGE_SIZE * pid.pageNumber());
            byte[] buffer = new byte[BufferPool.PAGE_SIZE];
            raf.read(buffer);
            raf.close();
            return new HeapPage((HeapPageId)pid, buffer);
        } catch (IOException e) {
            throw new IllegalArgumentException();
        }
    }

    // see DbFile.java for javadocs
    public void writePage(Page page) throws IOException {
        // some code goes here
    	// not necessary for this assignment
    }

    /**
     * Returns the number of pages in this HeapFile.
     */
    public int numPages() {
        // some code goes here
        return (int) Math.ceil(this.file.length() / BufferPool.PAGE_SIZE);
    }

    // see DbFile.java for javadocs
    public ArrayList<Page> insertTuple(TransactionId tid, Tuple t)
            throws DbException, IOException, TransactionAbortedException {
        // some code goes here
    	// not necessary for this assignment
        return null;
    }

    // see DbFile.java for javadocs
    public ArrayList<Page> deleteTuple(TransactionId tid, Tuple t) throws DbException,
            TransactionAbortedException {
        // some code goes here
    	// not necessary for this assignment
        return null;
    }

    private class HeapFileIterator implements DbFileIterator, Serializable {
        
        private static final long serialVersionUID = 1L;
        private int fileId;
        private int numPages;
        private TransactionId tid;
        private int curPageNum;
        private HeapPage curPage;
        // type is not HeapPageIterator because that's a private class
        private Iterator<Tuple> curPageIterator;
        private boolean open;

        public HeapFileIterator(int fileId, int numPages, TransactionId tid) {
            this.fileId = fileId;
            this.numPages = numPages;
            this.tid = tid;
            this.open = false;
        }

        @Override
        public void open() throws DbException, TransactionAbortedException {
            this.getHeapPage(0);
        }

        @Override
        public boolean hasNext() throws DbException, TransactionAbortedException {
            return open ? this.curPageNum < this.numPages - 1 || this.curPageIterator.hasNext() : false;
        }

        @Override
        public Tuple next() throws DbException, TransactionAbortedException, NoSuchElementException {
            if (open) {
                if (this.hasNext() && curPageIterator.hasNext()) {
                    return this.curPageIterator.next();
                } else {
                    this.getHeapPage(this.curPageNum + 1);
                    return this.curPageIterator.next();
                }
            } else {
                throw new NoSuchElementException();
            }
        }

        @Override
        public void rewind() throws DbException, TransactionAbortedException {
            this.getHeapPage(0);
        }

        @Override
        public void close() {
            this.open = false;
        }

        /**
         * Point the current file iterator to a specific HeapPage in the HeapFile.
         * 
         * @param pageNum The page number to point to.
         * @throws DbException
         * @throws TransactionAbortedException
         */
        private void getHeapPage(int pageNum) throws DbException, TransactionAbortedException {
            this.curPageNum = pageNum;
            HeapPageId heapPageId = new HeapPageId(this.fileId, this.curPageNum);
            this.curPage = (HeapPage) Database.getBufferPool().getPage(this.tid, heapPageId, Permissions.READ_WRITE);
            this.curPageIterator = this.curPage.iterator();
            this.open = true;
        }
    }

    // see DbFile.java for javadocs
    public DbFileIterator iterator(TransactionId tid) {
        // some code goes here
        return new HeapFileIterator(this.id, this.numPages(), tid);
    }
}

