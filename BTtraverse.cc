////////////////////////////////////////////////////////////////
//
// BTtraverse.cc - demonstration of Binary Tree Traversal.
//
// This file contains the code of building a binary tree from 
// vector of strings(level-by-level representation), printing the
// binary tree and three traversal methods: preorder, inorder and
// postorder. 
//
// Preorder traversal: (i) Visit the root, (ii) Traverse the left 
// subtree, and (iii) Traverse the right subtree.
//
// Inorder traversal: (i) Traverse the leftmost subtree starting at
// the left external node, (ii) Visit the root, and (iii) Traverse 
// the right subtree starting at the left external node.
//
// Postorder traversal: (i) Traverse all the left external nodes 
// starting with the leftmost subtree which is then followed by 
// bubble-up all the internal nodes, (ii) Traverse the right subtree
// starting at the left external node which is then followed by 
// bubble-up all the internal nodes, and (iii) Visit the root.
//
// For example, given sequence {1,2,3,#,#,4,#,#,5}, following binary 
// tree can be built:
// 	   1
//	  / \
//	 2   3
//	    /
//	   4
//	    \
//	     5
// The preorder traversal is: 1,2,3,4,5.
// The inorder traversal is: 2,1,4,5,3.
// The postorder traversal is: 2,5,4,3,1.
//
// Version 1, May 25th by Bo Yang(bonny95@gmail.com).
// 
////////////////////////////////////////////////////////////////
#include <iostream>
#include <vector>
#include <stack>
#include <string>
#include <cstdlib>
#include <queue>

using namespace std;

/**
 * Definition for binary tree
 */
struct TreeNode {
    int val;
    TreeNode *left;
    TreeNode *right;
	TreeNode() : val(0), left(NULL), right(NULL) {}
    TreeNode(int x) : val(x), left(NULL), right(NULL) {}
};
 
class BinaryTree {
public:
	BinaryTree() { tree=NULL;layers=0; }
	~BinaryTree() {
		if(tree!=NULL)
			delete [] tree;
	}

	// Preorder Traversal:
	//	(i) Visit the root, (ii) Traverse the left subtree, and 
	//	(iii) Traverse the right subtree. 	
	vector<int> PreorderTraversal(TreeNode *root) {
		vector<int> trace;
		stack<TreeNode*> st;
		while(root!=NULL) {
			trace.push_back(root->val); // Visit the root
			if(root->left!=NULL) {	// Traverse the left subtree
				TreeNode* tmp=root;
				root=root->left;
				if(tmp->right!=NULL)
					st.push(tmp->right);	// store the root of the right subtree
			} else if(root->right!=NULL) {
				root=root->right;
			} else {
				if(st.empty()) {
					root=NULL;
				} else {
					root=st.top();
					st.pop();
				}
			}
		} // end of while
		return trace;
	}

	// Inorder Traversal:
	// 	(i) Traverse the leftmost subtree starting at the left external node, 
	// 	(ii) Visit the root, and (iii) Traverse the right subtree starting at 
	// 	the left external node.
    vector<int> InorderTraversal(TreeNode *root) {
		vector<int> trace;
		stack<TreeNode> st;
        while(root!=NULL) {
			// Find the left-most node
			while(root->left!=NULL) {
				TreeNode tmp=*root;
				root=root->left;
				tmp.left=NULL;
				st.push(tmp);	// store the root of the right subtree
			}
			trace.push_back(root->val);
			// Handle the right subtree
			if(root->right!=NULL) {
				root=root->right;
			} else {
				if(st.empty()) {
					root=NULL;
				} else {
					root=&(st.top());
					st.pop();
				}
			}
		}
		return trace;
    }

	// Postorder Traversal:
	// 	(i) Traverse all the left external nodes starting with the leftmost
	// 	subtree which is then followed by bubble-up all the internal nodes, 
	// 	(ii) Traverse the right subtree starting at the left external node 
	// 	which is then followed by bubble-up all the internal nodes, and 
	// 	(iii) Visit the root.
	vector<int> PostorderTraversal(TreeNode *root) {
		vector<int> trace;
		stack<TreeNode> st;
        while(root!=NULL) {
			// Find the left-most node
			while(root->left!=NULL) {
				TreeNode tmp=*root;
				root=root->left;
				tmp.left=NULL;
				st.push(tmp);	// store the root of the right subtree
			}
			// Handle the right subtree
			if(root->right!=NULL) {
				TreeNode tmp=*root;
				root=root->right;
				tmp.left=NULL;
				tmp.right=NULL;
				st.push(tmp);	// store the root
			} else {
				trace.push_back(root->val);	// Print root at last
				if(st.empty()) {
					root=NULL;
				} else {
					root=&(st.top());
					st.pop();
				}
			}
		}
		return trace;
	}

	void PrintTraversal(vector<int>& vec, string type) {
		cout<<type<<" traversal: ";
		for(vector<int>::iterator it=vec.begin(); it!=vec.end();++it) {
			cout<<*it<<" ";
		}
		cout<<endl;
	}

	TreeNode* BuildTree(vector<string>& t) {
		tree=new TreeNode[t.size()];

		// Build binary tree from vector of strings, where # denotes an invalid node.
		//
		// The main idea is to parse vector of strings(nodes) layer by layer. 
		// The first item in the vector should be the root node, and the number of
		// first layer is one. When parsing the first layer, count the nodes of the
		// second layer, and so on.
		int idx=0;
		int nodes_cur_layer=1;
		vector<string>::iterator it=t.begin(); 
		while(idx<t.size()) {
			int nodes_next_layer=0; // all nodes, including #s
			int vi=0;	// index of valid nodes in current layer
			for(int i=0;i<nodes_cur_layer;++i) {
				if(*(it+i)=="#") { // Skip #s
					continue;
				}

				int left=nodes_cur_layer+2*vi;
				int right=nodes_cur_layer+2*vi+1;
				if(idx+left<t.size() && *(it+left)!="#" ) {
					tree[idx+i].left=&tree[idx+left];
				} else {
					tree[idx+i].left=NULL;
				}
				if(idx+right<t.size() && *(it+right)!="#") {
					tree[idx+i].right=&tree[idx+right];
				} else {
					tree[idx+i].right=NULL;
				}

				nodes_next_layer+=2;
				tree[idx+i].val=atoi((it+i)->c_str());
				vi++;
			}

			idx+=nodes_cur_layer;
			it+=nodes_cur_layer;
			nodes_cur_layer=nodes_next_layer;
			layers++;
		}

		return &tree[0];	// root of the tree
	}

	// Print binary tree level by level
	void PrintTree(TreeNode *root) {
		queue<TreeNode*> q;
		TreeNode* tmp=root;
		q.push(tmp);
		int nodes_cur_layer=1;
		int nodes_next_layer=0;
		while(nodes_cur_layer>0) {
			for(int i=0;i<nodes_cur_layer;++i) {
				tmp=q.front();
				q.pop();

				cout<<tmp->val<<" ";

				if(tmp->left!=NULL) {
					q.push(tmp->left);
					nodes_next_layer++;
				}
				if(tmp->right!=NULL) {
					q.push(tmp->right);
					nodes_next_layer++;
				}
			}
			cout<<endl;
			nodes_cur_layer=nodes_next_layer;
			nodes_next_layer=0;
		}
	}

private:
	TreeNode* tree;
	int layers;	// number of layers
};

int main() {
	string str1[]={"1","2","3","#","#","4","#","#","5"};
	string str2[]={"7","1","9","0","3","8","10","#","#","2","5","#","#","#","#","#","#","4","6"};
	string str3[]={"1","#","2","3","#","#","4","5","#"};
	string str4[]={"1","#","2","#","3","#","4"};
	string str5[]={"1","2","#","3","#","4","#"};

	vector<string> tree1;
	vector<string> tree2;
	vector<string> tree3;
	vector<string> tree4;
	vector<string> tree5;
	tree1.insert(tree1.begin(),str1,str1+9);
	tree2.insert(tree2.begin(),str2,str2+19);
	tree3.insert(tree3.begin(),str3,str3+9);
	tree4.insert(tree4.begin(),str4,str4+7);
	tree5.insert(tree5.begin(),str5,str5+7);

	BinaryTree bt;
	TreeNode* root=bt.BuildTree(tree2);
	bt.PrintTree(root);
	
	vector<int> vec=bt.PreorderTraversal(root);
	bt.PrintTraversal(vec,"Preorder");
	vec=bt.InorderTraversal(root);
	bt.PrintTraversal(vec,"Inorder");
	vec=bt.PostorderTraversal(root);
	bt.PrintTraversal(vec,"Postorder");

	return 0;
}
