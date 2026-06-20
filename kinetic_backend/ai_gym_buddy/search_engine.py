import re
import logging
from django.db.models import Q
from .models import KnowledgeArticle, KnowledgeQA, KnowledgeCategory

logger = logging.getLogger(__name__)

STOP_WORDS = {
    'the', 'is', 'at', 'which', 'on', 'and', 'a', 'an', 'to', 'in', 'of', 'for',
    'with', 'about', 'how', 'what', 'why', 'where', 'who', 'should', 'can', 'do',
    'i', 'you', 'he', 'she', 'they', 'we', 'my', 'your', 'his', 'her', 'their', 'our'
}

class KnowledgeBaseSearchEngine:
    """
    Search engine for both articles and Q&A records.
    Implements keyword search, category matching, similarity ranking, and vector hooks.
    """

    @staticmethod
    def tokenize(text: str) -> list:
        """Tokenizes text, removes punctuation, lowercases and filters stop words."""
        if not text:
            return []
        text = text.lower()
        words = re.findall(r'\b\w+\b', text)
        return [w for w in words if w not in STOP_WORDS and len(w) > 1]

    @classmethod
    def search(cls, query: str, gym=None, category_slug: str = None, 
               difficulty: str = None, limit: int = 10, language: str = 'en') -> list:
        """
        Search both KnowledgeArticle and KnowledgeQA.
        Calculates similarity scores and ranks the best answers.
        """
        tokens = cls.tokenize(query)
        results = []

        # 1. Search Articles
        articles_qs = KnowledgeArticle.objects.filter(is_active=True)
        if gym:
            articles_qs = articles_qs.filter(Q(gym__isnull=True) | Q(gym=gym))
        else:
            articles_qs = articles_qs.filter(gym__isnull=True)

        if category_slug:
            articles_qs = articles_qs.filter(category__slug=category_slug)
        if difficulty:
            articles_qs = articles_qs.filter(difficulty=difficulty)

        # 2. Search QAs
        qa_qs = KnowledgeQA.objects.filter(is_active=True, language=language)
        if gym:
            qa_qs = qa_qs.filter(Q(gym__isnull=True) | Q(gym=gym))
        else:
            qa_qs = qa_qs.filter(gym__isnull=True)

        if category_slug:
            qa_qs = qa_qs.filter(category__slug=category_slug)
        if difficulty:
            qa_qs = qa_qs.filter(difficulty=difficulty)

        # If no tokens, return featured articles/popular QA
        if not tokens:
            for art in articles_qs.order_by('-is_featured', '-view_count')[:limit]:
                results.append({
                    'type': 'article',
                    'id': str(art.id),
                    'title': art.title,
                    'content': art.content,
                    'summary': art.summary,
                    'category': art.category.name if art.category else 'General',
                    'difficulty': art.difficulty,
                    'score': 1.0 + (0.5 if art.is_featured else 0.0),
                    'safety_notes': '',
                    'related_topics': art.tags
                })
            for qa in qa_qs.order_by('-created_at')[:limit]:
                if len(results) >= limit:
                    break
                results.append({
                    'type': 'qa',
                    'id': str(qa.id),
                    'title': qa.question,
                    'content': qa.answer,
                    'summary': qa.answer[:200],
                    'category': qa.category.name,
                    'difficulty': qa.difficulty,
                    'score': 1.0,
                    'safety_notes': qa.safety_notes,
                    'related_topics': qa.related_topics
                })
            return sorted(results, key=lambda x: x['score'], reverse=True)[:limit]

        # Calculate scores based on token matching
        # Search Articles
        for art in articles_qs:
            score = 0.0
            title_lower = art.title.lower()
            content_lower = art.content.lower()
            keywords_lower = (art.keywords or '').lower()
            tags_lower = art.tags.lower()

            for token in tokens:
                if token in title_lower:
                    score += 5.0  # High boost for title match
                if token in keywords_lower:
                    score += 3.0  # Medium boost for keywords
                if token in tags_lower:
                    score += 2.0  # Tag match
                if token in content_lower:
                    score += 1.0  # Low boost for body content

            if score > 0:
                if art.is_featured:
                    score *= 1.2
                results.append({
                    'type': 'article',
                    'id': str(art.id),
                    'title': art.title,
                    'content': art.content,
                    'summary': art.summary,
                    'category': art.category.name if art.category else 'General',
                    'difficulty': art.difficulty,
                    'score': round(score, 2),
                    'safety_notes': '',
                    'related_topics': art.tags
                })

        # Search QAs
        for qa in qa_qs:
            score = 0.0
            q_lower = qa.question.lower()
            a_lower = qa.answer.lower()
            kw_lower = (qa.keywords or '').lower()
            topics_lower = qa.related_topics.lower()

            for token in tokens:
                if token in q_lower:
                    score += 6.0  # Higher boost for matching the question directly
                if token in kw_lower:
                    score += 3.5
                if token in topics_lower:
                    score += 2.0
                if token in a_lower:
                    score += 1.0

            if score > 0:
                results.append({
                    'type': 'qa',
                    'id': str(qa.id),
                    'title': qa.question,
                    'content': qa.answer,
                    'summary': qa.answer[:200],
                    'category': qa.category.name,
                    'difficulty': qa.difficulty,
                    'score': round(score, 2),
                    'safety_notes': qa.safety_notes,
                    'related_topics': qa.related_topics
                })

        # Sort by score descending
        results = sorted(results, key=lambda x: x['score'], reverse=True)
        return results[:limit]

    @classmethod
    def get_related_questions(cls, matched_result: dict, gym=None, limit: int = 4) -> list:
        """Finds related questions based on category and matching keywords."""
        category_name = matched_result.get('category')
        related_topics = matched_result.get('related_topics', '')
        
        qs = KnowledgeQA.objects.filter(is_active=True)
        if gym:
            qs = qs.filter(Q(gym__isnull=True) | Q(gym=gym))
        else:
            qs = qs.filter(gym__isnull=True)

        if category_name:
            qs = qs.filter(category__name__iexact=category_name)

        # Exclude current matching item
        exclude_id = matched_result.get('id')
        if exclude_id:
            qs = qs.exclude(id=exclude_id)

        # Basic filtering by overlapping words in topics/questions
        tokens = cls.tokenize(related_topics)
        related = []
        for qa in qs:
            score = 0
            for token in tokens:
                if token in qa.question.lower():
                    score += 1
            related.append((qa, score))

        # Sort by score and return questions
        related = sorted(related, key=lambda x: x[1], reverse=True)
        return [r[0].question for r in related[:limit]]

    # --- Future Vector Search Hooks ---
    @classmethod
    def embed_query(cls, query: str) -> list:
        """
        Hook for future vector embeddings.
        Should return a dense vector (e.g. 768 float values).
        """
        # Placeholder vector
        return [0.0] * 768

    @classmethod
    def vector_search(cls, query_vector: list, gym=None, limit: int = 5) -> list:
        """
        Hook for future cosine similarity search in pgvector or similar database.
        """
        # Placeholder search fallback
        return []
